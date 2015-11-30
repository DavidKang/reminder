class TodosController < ApplicationController
  before_filter :set_todo, only: %i[done reopen]
  before_filter :set_week_days, only: %i[create import]

  def index
    respond_to do |format|
      @todos = Todo.pending.order(:due, :project)
      @date = @todos.map { |todo| [todo.due] }
      @date << Date.today
      @date = @date.flatten.compact.uniq.sort
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
    if !params["todo"]["due"].present?
      @todo.due = Date.today
    else
      day = @week_days[params["todo"]["due"].to_sym]
      if day
        if [:today, :tomorrow].include? day
          @todo.due = Date.send(day)
        else
          @todo.due = Date.next_week.send(day)
        end
      end
    end
    respond_to do |format|
      if @todo.save
        SlackNotifierWorker.perform_at(@todo.due + @todo.at.hours, @todo.id )
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
        if day = @week_days[todo['due']]
          if [:today, :tomorrow].include? day
            todo['due'] = Date.send(day)
          else
            todo['due'] = Date.next_week.send(day)
          end
        end
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

  def set_week_days
    @week_days = {
      'today': :today,
      'tomorrow': :tomorrow,
      'lun': :monday,
      'mar': :tuesday,
      'mier': :wednesday,
      'jue': :thursday,
      'vie': :fryday,
      'sab': :saturday,
      'dom': :sunday
    }
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
