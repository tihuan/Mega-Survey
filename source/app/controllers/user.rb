post "/create_user" do
  user = User.create(username: params[:login], password: params[:password])
  if user.valid?
    session[:user_id] = user.id
    redirect "/"
  else
    @errors = user.errors.full_messages
    erb :index
  end
end

post "/signin" do
  user = User.find_by_username(params[:login])
  session[:user_id] = user.authenticate(params[:password])
  if session[:user_id]
    # successfully authenticated; set up session
    # AJAX renders "/surveys" if JSON is true
    { auth: true }.to_json
  else
    # an error occurred, jQuery displays an error
    # Send back to AJAX
    { auth: false }.to_json
  end
end

get "/user_id/:id" do
  if params[:id] == session[:user_id]
    user = User.find(session[:user_id])
    question_ids = user.answers.map { |ans| ans.question_id }.uniq
    answered_survey_ids = Survey.find(question_id)
    @surveys = user.surveys
    @answered_surveys = Survey.find(answered_survey_ids) # prepare an array of question ID's for view to
    erb :user
  else
    redirect "/"
  end
end

get "/signout" do
  session.clear
  redirect "/"
end
