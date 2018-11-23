## SONATA - Gatekeeper
##
## Copyright (c) 2015 SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
## ALL RIGHTS RESERVED.
## 
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
## 
##     http://www.apache.org/licenses/LICENSE-2.0
## 
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## 
## Neither the name of the SONATA-NFV [, ANY ADDITIONAL AFFILIATION]
## nor the names of its contributors may be used to endorse or promote 
## products derived from this software without specific prior written 
## permission.
## 
## This work has been performed in the framework of the SONATA project,
## funded by the European Commission under Grant number 671517 through 
## the Horizon 2020 and 5G-PPP programmes. The authors would like to 
## acknowledge the contributions of their colleagues of the SONATA 
## partner consortium (www.sonata-nfv.eu).
# frozen_string_literal: true
# encoding: utf-8
require 'sinatra'
require 'json'
require 'tng/gtk/utils/logger'
require 'securerandom'
require 'tng/gtk/utils/application_controller'

class RecordsController < Tng::Gtk::Utils::ApplicationController
  LOGGER=Tng::Gtk::Utils::Logger
  LOGGED_COMPONENT=self.name
  @@began_at = Time.now.utc
  LOGGER.info(component:LOGGED_COMPONENT, operation:'initializing', start_stop: 'START', message:"Started at #{@@began_at}")

  ERROR_RECORD_NOT_FOUND="No record with UUID '%s' was found"
  
  get '/?' do 
    msg='.'+__method__.to_s+' (many)'
    captures=params.delete('captures') if params.key? 'captures'
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"params=#{params}")
    result = FetchTestResultsService.call(symbolized_hash(params))
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"result=#{result}")
    halt 404, {}, {error: "No records fiting the provided parameters ('#{params}') were found"}.to_json if result.to_s.empty? # covers nil
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:result.to_json, status: '200')
    halt 200, {}, result.to_json
  end
  
  get '/:record_uuid/?' do 
    msg='.'+__method__.to_s+' (single)'
    captures=params.delete('captures') if params.key? 'captures'
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"params['record_uuid']='#{params['record_uuid']}")
    result = FetchTestResultsService.call(uuid: params['record_uuid'])
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:"result=#{result}")
    if result == {}
      LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:ERROR_RECORD_NOT_FOUND % params['record_uuid'], status: '404')
      halt 404, {}, {error:ERROR_RECORD_NOT_FOUND % params['record_uuid']}.to_json
    end
    LOGGER.debug(component:LOGGED_COMPONENT, operation:msg, message:result.to_json, status: '200')
    halt 200, {}, result.to_json
  end

  options '/?' do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'GET,DELETE'      
    response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With'
    halt 200
  end
    
  private  
  def symbolized_hash(hash)
    Hash[hash.map{|(k,v)| [k.to_sym,v]}]
  end
  LOGGER.info(component:LOGGED_COMPONENT, operation:'initializing', start_stop: 'STOP', message:"Ended at #{Time.now.utc}", time_elapsed:"#{Time.now.utc-began_at}")
end
