_log = -> console.log.apply console, arguments
__log = (title) -> -> 
	args = _.toArray arguments
	args.unshift title
	console.log.apply console, args

pauses = $('.pause-play').asEventStream 'click'
pauses.onValue __log "pause/play"

rotateLeft = (pos) -> [pos[0], -pos[1]]
rotateRight = (pos) -> [-pos[0], pos[1]]

lefts = $('.left').asEventStream 'click'
rights = $('.right').asEventStream 'click'

actions = lefts.map(-> rotateLeft).merge(rights.map(-> rotateRight))
direction = actions.scan([0, 1], (x, f) -> f(x));
direction.onValue __log "direction change"