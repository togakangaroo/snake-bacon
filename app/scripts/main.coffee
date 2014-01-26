_log = -> console.log.apply console, arguments
__log = (title) -> -> 
	args = _.toArray arguments
	args.unshift title
	console.log.apply console, args

#draw board
board = $('.gameboard').html (_.flatten [
		"<ul class='rows'>"
		(_.map _.range(10), (y) -> [
			"<li class='row-#{y}'><ul class='cols'>"
			(_.map _.range(10), (x) -> "<li class='col-#{x} cell'></li>")
			"</ul></li>"
		])
		"</ul>"
	]).join ''
drawSnake = (positions) ->
	$('.cell', board).removeClass 'has-snake'
	_.each positions, (pos) -> $(".row-#{pos[0]} .col-#{pos[1]}", board).addClass 'has-snake'

pauses = $('.pause-play').asEventStream 'click'
pauses.onValue __log "pause/play"

rotateLeft = (pos) -> [pos[0], -pos[1]]
rotateRight = (pos) -> [-pos[0], pos[1]]

actions =       $('.left').asEventStream('click').map(-> rotateLeft)
		.merge( $('.right').asEventStream('click').map(-> rotateRight) )
direction = actions.scan([0, 1], (x, f) -> f(x));
direction.onValue __log "direction"

ticks = $('.tick').asEventStream 'click'

currentDirection = direction.sampledBy ticks

position = currentDirection.scan [0, 0], (a, b) -> [a[0]+b[0], a[1]+b[1]]
position.onValue __log "position"

position.map(Array).onValue drawSnake