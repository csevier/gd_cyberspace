extends Node
class_name Link, "res://addons/gd_cyberspace/link.svg"

export var link_location = "http://127.0.0.1:5000/"
export var pck  = "test.pck"
export var main_scene = "res://World.tscn"
var thread
var should_download = false

func _ready():
	var args = Array(OS.get_cmdline_args())
	if not args.has("host"):
		thread = Thread.new()
		thread.start(self, "download")
	
func _http_download_pck(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Download Failed")
	else:
		if _response_code == 404:
			print("Link failed to load. Reason...")
			print("Not Found: " + link_location + pck)
		else:
			print("World loaded from: " + link_location + pck)
			print("World written to: " + OS.get_user_data_dir() + "/" + pck)
			download_pck_hash()
			
func _http_pck_hash_check(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Hash Check Failed")
	else:
		if _response_code == 404:
			print("No Hash Present. Reason...")
			print("Not Found: " + link_location + pck)
		else:
			var server_hash = _body.get_string_from_utf8()
			print("Hash Recieved: " + server_hash)
			var hash_file = File.new()
			hash_file.open("user://"+pck+".hash", File.READ)
			var pck_hash = hash_file.get_line()
			hash_file.close()
			print("Hash Current: " + pck_hash)
			if pck_hash == server_hash:
				print("Hash Matches skipping download and using local: " + pck)
			else:
				print("Updating local: " + pck)
				download_pck()
				
func _http_download_pck_hash(result, _response_code, _headers, _body):
	if result != OK:
		push_error("Hash Download Failed")
	else:
		if _response_code == 404:
			print("No Hash Present. Reason...")
			print("Not Found: " + link_location + pck)
		else:
			var server_hash = _body.get_string_from_utf8()
			print("Hash Recieved: " + server_hash)
			var hash_file = File.new()
			hash_file.open("user://"+pck+".hash", File.WRITE)
			hash_file.store_string(server_hash)
			hash_file.close()
			print("Has File Written at: " + OS.get_user_data_dir()+"/"+pck+".hash")
	
func download():
	var file = File.new()
	if file.file_exists("user://"+pck):
		print("PCK Exists checking hash")
		compare_pck_hash()
	else:
		print(pck + " not found locally, downloading.")
		download_pck()
			
func change_world():
	var success = ProjectSettings.load_resource_pack("user://"+pck)
	if success:
		print("changing world to: " + OS.get_user_data_dir() + "/" + pck)
		var imported_scene = load(main_scene)
		get_tree().change_scene_to(imported_scene)

func execute():
	change_world()
	
func _exit_tree():
	thread.wait_to_finish()
	
func download_pck():
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_http_download_pck")
	http.set_download_file("user://"+pck) 
	var request = http.request(link_location+pck)
	if request != OK:
		push_error("Http request error")
		
func download_pck_hash():
	var http_hash_file = HTTPRequest.new()
	add_child(http_hash_file)
	http_hash_file.connect("request_completed", self, "_http_download_pck_hash")
	var request = http_hash_file.request(link_location+pck, ["hash: true"])
	if request != OK:
		push_error("Http request error")
		
func compare_pck_hash():
	var http_hash = HTTPRequest.new()
	add_child(http_hash)
	http_hash.connect("request_completed", self, "_http_pck_hash_check")
	var request = http_hash.request(link_location+pck, ["hash: true"])
	if request != OK:
		push_error("Http request error")
