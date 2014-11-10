# encoding: utf-8
class ApiController < ApplicationController
	respond_to :json
	def login
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

	def get_homeworks
	end
end