_log = -> console.log.apply console, arguments
__log = (title) -> -> 
	args = _.toArray arguments
	args.unshift title
	console.log.apply console, args

#draw board
[boardHeight, boardWidth] = [10, 10]
board = $('.gameboard').html (_.flatten [
		"<ul class='rows'>"
		(_.map _.range(boardHeight), (y) -> [
			"<li class='row-#{y}'><ul class='cols'>"
			(_.map _.range(boardWidth), (x) -> "<li class='col-#{x} cell'></li>")
			"</ul></li>"
		])
		"</ul>"
	]).join ''
drawSnake = (positions) ->
	$('.cell', board).removeClass 'has-snake'
	_.each positions, (pos) -> $(".row-#{pos[0]} .col-#{pos[1]}", board).addClass 'has-snake'

timer = Bacon.interval 1000

pauses = $('.pause-play').asEventStream('click').scan 1, (e, x) -> -x
pauses.onValue __log "pause/play"

rotateLeft = (pos) -> [-pos[1], pos[0]]  #(-1, 0) (0, -1) (1, 0) (0, 1 )
rotateRight = (pos) -> [pos[1], -pos[0]]

keys = $(document).asEventStream('keydown').map('.keyCode')
lefts  = keys.filter (x) -> x == 37
rights = keys.filter (x) -> x == 39

actions = lefts.map(-> rotateLeft).merge( rights.map(-> rotateRight) )
direction = actions.scan([0, 1], (x, f) -> f(x));
direction.onValue __log "direction"

currentDirection = direction.sampledBy timer

addPosition = (a, b) -> [ (a[0]+b[0]+boardHeight) % boardHeight, (a[1]+b[1]+boardWidth) % boardWidth ]
position = currentDirection.scan [0, 0], addPosition

position.slidingWindow(3).onValue drawSnake