require 'sinatra'
require 'sinatra/namespace'
require 'sinatra/json'
require 'json'
require './sqlite_driver'


namespace '/api' do
    before do
        content_type 'application/json'
    end

    ## Custom Method for Getting Request body
    def getBody (req)
        ## Rewind the body in case it has already been read
        req.body.rewind
        ## parse the body
        return JSON.parse(req.body.read)
    end
    
    
    # Get all posts
    get '/posts' do
        # Return as JSON
        json :data => get_posts
    end
    
    # Get single post
    get '/posts/:id' do
        # return a particular post as json based on the id param from the url
        # Params always come to a string so we convert to an integer
        id = params["id"].to_i
        json :data => get_post(id)
    end
    
    # Create post
    post '/posts' do
        # Pass the request into the custom getBody function
        body = getBody(request)
        # create the new post
        result = create_post(body["u_id"], body["title"], body["body"])
        # return the result
        json :data => "SUCCESS"
    end
    
    # Update post
    patch '/posts/:id' do
        # get the id from params
        id = params["id"].to_i
        # get the request body
        body = getBody(request)
        #update the item in question
        update_post(id, body['title'], body['body'])
        #return the result
        json :data => "SUCCESS"
    end

    # Update single post
    patch '/posts/like/:id' do
        id = params["id"].to_i
        like_post(id)
        # return result
        json :data => "SUCCESS"
    end
    
    # Delete post
    delete '/posts/:id' do
        id = params["id"].to_i
        # delete the item
        delete_post(id)
        # return the result
        json :data => "SUCCESS"
    end

    # Register / Create new user
    post '/register' do
        body = getBody(request)
        create_user(body["username"], body["password"], body["email"], body["bio"])
        # Return result
        json :data => "SUCCESS"
    end
    
    # Login a user with username, password
    post '/login' do
        body = getBody(request)
        result = login_user(body["username"], body["password"])
        # Return the result
        json :data => result
    end

    # Get a user with userid [not email or username]
    get '/user/:id' do
        id = params["id"].to_i
        # Return user as JSON
        json :data => get_user(id)
    end

    # Delete user and associated posts [keeps record, but marks delete]
    delete '/user/:id' do
        id = params["id"].to_i
        delete_user(id)
        json :data => "SUCCESS"
    end

    # Update certain fields of user
    patch '/user/:id' do
        id = params["id"].to_i
        body = getBody(request)
        update_user(id, body["username"], body["password"], body["email"], body["bio"])
        json :data => "SUCCESS"
    end
end

