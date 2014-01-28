_log = -> console.log.apply console, arguments
__log = (title) -> -> 
	args = _.toArray arguments
	args.unshift title
	console.log.apply console, args

#draw board
[boardHeight, boardWidth] = [10, 10]
$board = $('.gameboard').html (_.flatten [
		"<ul class='rows'>"
		(_.map _.range(boardHeight), (y) -> [
			"<li class='row-#{y}'><ul class='cols'>"
			(_.map _.range(boardWidth), (x) -> "<li class='col-#{x} cell'></li>")
			"</ul></li>"
		])
		"</ul>"
	]).join ''
$selectPos = (pos) -> $(".row-#{pos[0]} .col-#{pos[1]}", $board)

drawSnake = (positions) ->
	$('.cell', $board).removeClass 'has-snake'
	_.each positions, (pos) -> $selectPos(pos).addClass 'has-snake'
drawApple = (pos) -> 
	$('.has-apple', $board).removeClass 'has-apple'
	$selectPos(pos).addClass 'has-apple'

####################
Bacon.Observable.prototype.slidingWindowBy = (lengthStream) ->
	new Bacon.EventStream (sink) =>
		buf = []
		length = 0
		lengthStream.onValue (n) -> length = n
		@onValue (x) ->
			buf.unshift x
			buf = buf.slice 0, length
			sink (new Bacon.Next buf)
 ####################

pauses = $('.pause-play').asEventStream('click').scan true, (x) -> !x
pauses.onValue $.fn.toggleClass.bind $('.pause-play'), 'playing'

timer = Bacon.interval(500).filter pauses

rotateLeft = (pos) -> [-pos[1], pos[0]]  #(-1, 0) (0, -1) (1, 0) (0, 1 )
rotateRight = (pos) -> [pos[1], -pos[0]]

keys = $(document).asEventStream('keydown').map('.keyCode')
lefts  = keys.filter (x) -> x == 37
rights = keys.filter (x) -> x == 39

actions = lefts.map(-> rotateLeft).merge( rights.map(-> rotateRight) )
direction = actions.scan([0, 1], (x, f) -> f(x));

currentDirection = direction.sampledBy timer

normalizeDimension = (val, dim) -> (val+dim) % dim
addPosition = (a, b) -> [ (normalizeDimension a[0]+b[0], boardHeight), (normalizeDimension a[1]+b[1], boardWidth) ]
position = currentDirection.scan [0, 0], addPosition

apple = ->
	applePos = [ (normalizeDimension (_.random boardHeight), boardHeight), (normalizeDimension (_.random boardWidth), boardWidth) ]
	snakeEatsApple = position.filter (p) -> p[0] == applePos[0] && p[1] == applePos[1]
	snakeEatsApple.take(1).flatMapLatest(apple).toProperty(applePos)
appleStream = apple()
appleStream.onValue drawApple

snakeLength = appleStream.map(1).scan 0, (a, b) -> a+b
snakePositions = position.slidingWindowBy(snakeLength)
snakePositions.onValue drawSnake

snakeDeath = snakePositions
				.filter (positions) -> _.any positions, (p1) -> _.any _.without(positions, p1), (p2) -> p1[0] == p2[0] && p1[1] == p2[1]
snakeDeath.onValue $.fn.addClass.bind $board, 'death'