require 'json'

class UpdateChecker
  def self.check
    begin
      content = JSON.parse(open('https://dweet.io/get/latest/dweet/for/ddist2015-version').read)
      return if content['with'] == 404
      newest_version = content['with'].first['content']['version'].to_i
      current_version = File.read('version').to_i
      if newest_version > current_version
        puts "There is a newer version of the tester available (#{newest_version}, you have #{current_version}). Please update!".red
      end
    rescue => ex
      puts ex.message
    end
  end
end
