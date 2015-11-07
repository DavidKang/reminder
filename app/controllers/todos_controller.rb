class TodosController < ApplicationController
  def index
    respond_to do |format|
      @todos = Todo.all
      format.html
      format.json
    end
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)
    respond_to do |format|
      if @todo.save
        format.json { head :no_content }
      else
        format.json {
          render json: @todo.errors.full_messages, status: :unprocessable_entity
        }
      end
    end
  end

  def update
  end

  def destroy
  end

  private

  def todo_params
    params.require(:todo).permit(
      :title,
      :due
    )
  end

end
