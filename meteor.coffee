Meteor.Collection2.prototype.set = (id, updates, callback) ->
  @update({_id: id}, {$set: updates}, callback)

# Finds an array of items by array of their ids.
# Ensures they are in order and that reactivity still works.
Meteor.Collection2.prototype.findArray = (ids) ->
  return [] unless ids
  objs = @find({_id: {$in: ids}}).fetch()
  objs = objs.reduce (sum, obj) ->
    sum[obj._id] = obj
    sum
  , {}
  return ids.map (id) -> objs[id]