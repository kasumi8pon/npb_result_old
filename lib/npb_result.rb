require "npb_result/version"
require "open-uri"
require "date"
require "nokogiri"

module NpbResult
  def self.date(date = nil)
    get_results(nil, date)
    show
  end

  def self.team(team, date = nil)
    get_results(team, date)
    show
  end

  def self.show
    display = "#{@d.strftime("%Y年%m月%d日")}の結果 \n"
    if @result == []
      display = "試合なし"
    else
      @result.length.times do |i|
        display << "[#{@result[i][:status]}] #{@result[i][:away_team] }"
        case @result[i][:status]
        when "中止", "試合前"
          display << " ( - ) "
        else
          display << "(#{@result[i][:away_score]} - #{@result[i][:home_score]})"
        end
        display << "#{@result[i][:home_team]} \n"
      end
    end
    puts display
  end

  def self.get_results(date = nil, team = nil)
    get_date(date)
    input_url = "https://baseball.yahoo.co.jp/npb/schedule/?date=#{@d.strftime("%Y")}#{@d.strftime("%m")}#{@d.strftime("%d")}"
    doc = Nokogiri::HTML.parse(open(input_url).read)

    @team_list = doc.css(".yjMS.bb").map { |e| e.text }
    @score_list = doc.css(".score_r").map { |e| e.text }
    @status_list = doc.css("td.yjMSt").map { |e| e.text }
    @result = []
    make_result_list(@team_list.index(team))
  end

  def self.make_result_list(num)
    if num != nil then select_team(num) end
    (@team_list.length / 2).times do |i|
      @result.push({
        away_team: @team_list[i * 2],
        away_score: @score_list[i * 2],
        home_team: @team_list[i * 2 + 1],
        home_score: @score_list[i * 2 + 1],
        status: @status_list[i]})
    end
  end

  def self.select_team(num)
    num.even? ? away_num = num : away_num = num - 1
    @team_list = @team_list[away_num, 2]
    @score_list = @score_list[away_num, 2]
  end

  def self.get_date(date)
    @d = if date != nil && date.size == 8
      string_date = date.to_s
      Date.new(string_date[0..3].to_i, string_date[4..5].to_i, string_date[6..7].to_i)
    else
      Date.today
    end
  end

end
