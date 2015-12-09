# encoding: utf-8
class ApiController < ApplicationController
	require "mechanize"
	respond_to :json
	def login
		agent = Mechanize.new
		page = agent.get('http://aulavirtual.unisimonbolivar.edu.co/aulapregrado/login/index.php')

		form = page.form_with(:id => 'login')
		form.username = params[:username]
		form.password = params[:password]

		results = agent.submit(form)
		if defined? results.forms[1].values[0] == "guest"
  			render :json => {:status => 401, :message => "Error con el usuario o contraseña de unisimon"}
		else
			@user = User.new
	   		@user.username = params[:username]
		    @user.password = params[:password]
	   		@user.token = @user.generate_token

			samePage = agent.get('http://aulavirtual.unisimonbolivar.edu.co/aulapregrado/calendar/view.php').search("li a em").css("em")
	   		@user.name = samePage[0].text

	   		begin
		      	if @user.save
		  			render :json => {:status => 200, :id => @user.id, :name => @user.name, :message => 'Success', :token => @user.token}
	      		else	
	      			errors = @user.errors.full_messages.to_s.tr('][','')
	      			errors = errors.tr('"','')
	  	  			render :json => {:status => 401, :message => errors}
				end
	   		rescue Exception => e
	   			user = User.where(:username => params[:username]).where(:password => params[:password]).first
	  			render :json => {:status => 201, :id => user.id, :name => user.name, :message => 'Ya existia', :token => user.token}
	   		end
		end
	end

	def get_homeworks
		findUser = User.where('token = ?', params[:token]).first
		if findUser == nil
			invalid_user
		else
			agent = Mechanize.new
			page = agent.get('http://aulavirtual.unisimonbolivar.edu.co/aulapregrado/login/index.php')

			form = page.form_with(:id => 'login')
			form.username = findUser.username
			form.password = findUser.password

			results = agent.submit(form)
			@allHomeworks = []
			newPage = agent.get('http://aulavirtual.unisimonbolivar.edu.co/aulapregrado/calendar/view.php').search("div.eventlist").css("a")
			newPage.each do |result|
				@allHomeworks.push result
			end
			if not @allHomeworks.empty?
				render :json => {:status => 200, :id => findUser.id, :name => findUser.name, :homeworks => @allHomeworks.each_slice(4).each_with_index.map{|data, i| { _id: i, title: data[1].text, url: data[1]['href'], asignature: data[2].text, end_date: data[3].text}} }
			else
				render :json => {:status => 401, :id => findUser.id, :name => findUser.name, :message => 'Ve por unas cervezas porque no tienes tareas ;)'}
			end
		end
	end

	private
	def invalid_user
		render :json => {:status => 401, :success => false, :message => "Hay un error con tu token :'( </3"}
	end

end