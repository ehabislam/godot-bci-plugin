extends CanvasItem
class_name FlashScript

var blink_timer
var color_mode = null
var colormode = null
var send_data_timer
var recv_data_thread
var data = ""
var possible_frequencies = [1, 2, 5, 10, 15, 30, 60]
export var Enable_Flashing = true
#export(int, 256) var Diplay_frequency = 60
export(int, 256) var flash_frequency_hz = 1
export var signal_to_emit = "button_down"
export var host = "127.0.0.1"
export var port = "40674"

var _server = StreamPeerTCP.new()

var flash_interval = float(1)/flash_frequency_hz

signal send_data(data_string)
signal Frequency_updated(update)
signal node_received(node_name)

func _ready():
	var flash_interval = float(1)/flash_frequency_hz
	var send_data_interval = 5
	var err = _server.connect_to_host("127.0.0.1",40674)
	data = " --" + self.to_string() + "-" + str(flash_frequency_hz)+"hz" +"-- "
	blink_timer = Timer.new()
	send_data_timer = Timer.new()
	recv_data_thread = Thread.new()
	self.connect("node_received", self, "_apply_action")
	add_to_group("BCI_Enabled")	
	blink_timer.connect("timeout", self, "_on_blink_timeout")
	send_data_timer.connect("timeout", self, "_on_send_data")
	add_child(blink_timer)
	add_child(send_data_timer)
	
	
	self.start_blinking(flash_interval)
	self.start_datatimer(send_data_interval)

	if !_server.get_status() == _server.STATUS_CONNECTED:
		set_process(false)
	else:
		recv_data_thread.start(self, "_receive_data")
		print("Connected to: ",_server.get_connected_host(), ":", _server.get_connected_port())
		
func _apply_action(_signal):
	for n in get_tree().get_nodes_in_group("BCI_Enabled"):
		if _signal == n.name:
			n.emit_signal(signal_to_emit)
			
func _send_data():
	emit_signal("send_data")

func _on_blink_timeout():
	if Enable_Flashing:
		colormode = self.modulate
		if colormode == Color.white:
			self.modulate = Color.black
		else:
			self.modulate = Color.white

func start_blinking(interval):
	blink_timer.set_wait_time(interval)
	blink_timer.start()
	
func stop_blinking():
	blink_timer.stop()

func _on_datatimer_timeout():
	emit_signal("send_data", data)

func start_datatimer(interval):
	send_data_timer.set_wait_time(interval)
	send_data_timer.start()
	
func stop_datatimer():
	send_data_timer.stop()

func _receive_data():
	while _server.is_connected_to_host():
		var headset_data = ""
		var temp = ""
		while temp != "&":
			headset_data = headset_data + temp
			temp = _server.get_string(1) 
#		print(headset_data)
		emit_signal("node_received", headset_data)

func _on_send_data():
	if Enable_Flashing:
		var output = ""
		var separator = "\n"
		for s in get_tree().get_nodes_in_group("BCI_Enabled"):
			output +=  str(s)+ ", "+ str(s.flash_frequency_hz)+ "hz, " + "Is Flash Enabled: "+ str(s.Enable_Flashing) + separator
		_server.put_data(output.to_ascii())
#		print(output)

func _exit_tree():
	recv_data_thread.wait_to_finish() 
	_server.disconnect_from_host()
	
func _notification(what):	
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST: 
		get_tree().quit() # default behavior
