# encoding: utf-8
require 'sinatra-websocket'
require 'mqtt'
require 'pp'
require 'time'

class MyApp < Sinatra::Application
	get "/" do
		@title = "MQTT Push Test"
		erb :index
	end

	get "/error" do
		erb :error
	end


	get "/mqtt" do
		ip   = params[:ip]
		port = params[:port]
		qos  = params[:qos]
		topic  = params[:topic]
		puts ip, port, qos, topic
		if !request.websocket?
			erb :error
		else
			request.websocket do |ws|
				ws.onopen do
					MQTT::Client.connect(:host=>ip, :port=>port) do | conn |
						conn.get(topic) do |topic, message|
							message = message.force_encoding("UTF-8")
							ws.send "{\"time\":\"#{Time.new.to_s}\",\"msg\":\"#{message}\"}" 
						end
					end
				end

				ws.onmessage do |msg|
				end

				ws.onclose do
					puts "Web socket close"
				end
			end
		end
	end
end
