json.array! @todos.each do |todo|
  json.id todo.id
  json.due todo.due
  json.project todo.project
  json.title todo.title
end
