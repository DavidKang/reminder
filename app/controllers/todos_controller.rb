class TodosController < ApplicationController
  before_filter :set_todo, only: %i[done reopen]
  before_filter :set_valid_string, only: %i[create import]

  def index
    respond_to do |format|
      @todos = Todo.pending.order(:due)
      @date = @todos.map { |todo| [todo.due] }.flatten.uniq.compact
      format.json
      format.txt
      format.html
      format.js
    end
  end

  def done_todos
    respond_to do |format|
      @todos = Todo.finished
      format.json
    end
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.due.nil?
      @todo.due = Date.today
    else
      @todo.due = Date.send(params[:todo][:due]) if @valid_string.include? params[:todo][:due]
    end
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

  def import
    @todos = []
    params[:file].read.split("\n").each do |line|
      todo = YAML.load("{#{line}}")
      if todo['due'].nil?
        todo['due'] = Date.today
      else
        todo['due'] = Date.send(todo['due']) if @valid_string.include? todo['due']
      end
      t = Todo.find(todo.delete("id"))
      @todos << t
      t.update_attributes(todo)
    end
    head :no_content
  end

  def update
    @todo = Todo.find(params[:id])
    respond_to do |format|
      if @todo.update_attributes(todo_params)
        format.json { head :no_content}
      else
        format.json { head 500 }
      end
    end
  end

  def done
    @todo.done!
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def reopen
    @todo.reopen!
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def destroy
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def set_valid_string
    @valid_string = %w[today tomorrow]
  end

  def todo_params
    params.require(:todo).permit(
      :title,
      :due,
      :status,
      :project
    )
  end

end
