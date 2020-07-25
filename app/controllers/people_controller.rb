class PeopleController < ApplicationController
  def index
    @people = [Person.first] # TODO
  end

  def merge
    @people = [Person.first] # TODO
    redirect_to root_path
  end
end
