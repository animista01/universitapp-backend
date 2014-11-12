# encoding: utf-8
class ApiController < ApplicationController
	require "mechanize"
	respond_to :json
	def login
		agent = Mechanize.new
		page = agent.get('http://aulavirtual.unisimonbolivar.edu.co:8008/aulapregrado/')

		form = page.form_with(:id => 'login')
		form.username = params[:username]
		form.password = params[:password]

		results = agent.submit(form)
		if defined? results.forms[1].values[0] == "guest"
  			render :json => {:status => 401, :message => "Error con el usuario o contraseña"}
		else
			@user = User.new
	   		@user.username = params[:username]
		    @user.password = params[:password]
	   		@user.token = @user.generate_token
	   		begin
		      	if @user.save
		  			render :json => {:status => 200, :message => 'Success', :token => @user.token}
	      		else	
	      			errors = @user.errors.full_messages.to_s.tr('][','')
	      			errors = errors.tr('"','')
	  	  			render :json => {:status => 401, :message => errors}
				end
	   		rescue Exception => e
	   			user = User.where(:username => params[:username]).where(:password => params[:password]).first
	  			render :json => {:status => 201, :message => 'Ya existia', :token => user.token}
	   		end
		end
	end

	def get_homeworks
		sqlForUser = "select * from users where token = '#{params[:token]}' COLLATE utf8_bin"
		userId = User.find_by_sql(sqlForUser)
		if userId.empty?
			invalid_user
		else
			puts "#{userId.first.id}"
			render :json => {:status => 200, :message => "#{userId.first.id}"}
		end

	end
	def invalid_user
		render :json => {:status => 401, :success => false, :message => "Hay un error con tu token :'("}
	end
end