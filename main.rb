require 'rubygems'
require 'sinatra'
require 'tzinfo'

enable :sessions
set :session_secret, 'a super duper secret for this oh so important session data'

template = %{
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <title>Is It Cake Friday?</title>                  
    
      <meta charset="utf-8" />
      <meta name="description" content="A quck and easy way to determine if it is in fact currently Cake Friday" />
      <meta name="author" content="Matt Harmes" />
      <style type="text/css">
        body {
          background: #fff;
          color: #333;
          font-family: Helvetica, Verdana, Arial, sans-serif;
          margin: 10%;
          text-align: center;
        }
        
        #header {
          font-size: 8em;
        }
        
        #tag_line {
          padding: 20px;
        }
      </style>
    </head>
    
    <body>
      <h1 id="header"><%= @message %></h1>
      <p id="tag_line"><%= @tag_line %></p>
      
      <form name="timezone_select" method="post">
        <select name="timezone" id="timezone_list">
          <% tz_list.each do |tz| %>
            <option <%= "selected='true'" if tz == zone %>><%= tz %></option>
          <% end %>
          <input type="submit" name="timezone_submit" value="Try another timezone?" id="timezone_submit">
        </select>
      </form>
    </body>
  </html>
}

TZ_LIST = TZInfo::Timezone.all_country_zone_identifiers.sort.map { |i| i.gsub('_', ' ') }
DEFAULT_ZONE = 'America/Halifax'

get '/' do
  if is_cake_friday?
    @message = 'YES'
    @tag_line = "It's Cake Friday! Go ahead and stuff your face, you've earned it."
  else
    @message = 'NOPE'
    @tag_line = "Sorry, it's not Cake Friday yet."
  end
  
  erb(template, locals: {tz_list: TZ_LIST, zone: session[:timezone] || DEFAULT_ZONE})
end

post '/' do
  session[:timezone] = params[:timezone]
  logger.info("Setting the timezone to #{session[:timezone]}")
  
  redirect to('/')
end

def is_cake_friday?
  tz = session[:timezone] || DEFAULT_ZONE
  t = TZInfo::Timezone.get(tz.gsub(' ', '_')).utc_to_local(Time.now.utc)
  
  logger.info("Checking time #{t}")
  
  return true if t.friday? && t.day <= 7
  false
end