require 'open3'
require 'timeout'
require 'yaml'

require 'discordrb'

class Eliza
  def initialize
    respawn
  end

  def eval(message)
    loop do
      snd(message)
      output = recv
      return output if output
    end
  end

  def snd(message)
    @in.write("#{message}\n\n")
    @in.flush
  rescue IOError, Errno::EPIPE
    respawn
    retry
  end

  def recv
    Timeout.timeout(0.1) { recv_message.rstrip }
  rescue Timeout::ExitException
    nil
  rescue IOError, Errno::EPIPE
    respawn
  end

  def quit
    @in.close
    @out.close
    @wait.value
  end

  private

  def recv_message
    buffer = ''
    loop do
      buffer += @out.readchar
      return buffer if buffer.end_with?("\n\n")
    end
  end

  def respawn
    @in, @out, @wait = Open3.popen2('./eliza')
    nil
  end
end

CONFIG = YAML.load_file('./config.yaml')
discord_token = CONFIG['discord_token']
raise 'missing discord token' unless discord_token

eliza = Eliza.new

bot = Discordrb::Bot.new(token: discord_token)

def handle_message(eliza, event)
  input = event.message.content.gsub(/<@\d+>/, '')
  output = eliza.eval(input)
  event.respond(output)
end

bot.mention { |event| handle_message(eliza, event) }
bot.pm { |event| handle_message(eliza, event) }

bot.run
eliza.quit
