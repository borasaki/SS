GDPC                �                                                                      
   T   res://.godot/exported/133200997/export-2a9725ce195a9960d0e7a251a59366de-example.scn             f��b�)��Kˆu\�    ,   res://.godot/global_script_class_cache.cfg  P#             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex0      �      �Yz=������������       res://.godot/uid_cache.bin  0'      <       �jC�!��M �nV    4   res://addons/coi_serviceworker/coi_export_plugin.gd         �      �����.o���d`][�E    ,   res://addons/coi_serviceworker/coi_plugin.gd�      a      k`f�w�OvPN����<%       res://example.tscn.remap�"      d       �/�|_\=3���#�U�       res://icon.svg  p#      �      C��=U���^Qu��U3       res://icon.svg.import   "      �       ��X�R4i��:u�u       res://project.binaryp'      �      ���证S1&'�.�    ��p�X�@tool
extends EditorExportPlugin

const JS_FILE = "coi-serviceworker.min.js"

var plugin_path: String = get_script().resource_path.get_base_dir()
var exporting_web := false
var export_path := ""
var update_export_options := true

func _get_name() -> String:
	return "CoiServiceWorker"

func _get_export_options(platform: EditorExportPlatform) -> Array[Dictionary]:
	return [
		{
			"option": {
				"name": "include_coi_service_worker",
				"type": TYPE_BOOL
			},
			"default_value": true
		},
		{
			"option": {
				"name": "iframe_breakout",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": "Disabled,Same Tab,New Tab,New Window"
			},
			"default_value": "Disabled"
		}
	]

func _should_update_export_options(platform: EditorExportPlatform) -> bool:
	if not platform is EditorExportPlatformWeb: return false
	var u = update_export_options
	update_export_options = false
	return u

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	if features.has("web"):
		if not has_method("get_option") or get_option("include_coi_service_worker"):
			exporting_web = true
		export_path = path
		if has_method("get_option") and get_option("iframe_breakout") != "Disabled":
			if export_path.ends_with("index.html"):
				push_error("ERROR: cannot export as index.html with generate_index_popout option set")
			else:
				var html = POPOUT_INDEX_HTML
				var method = get_option("iframe_breakout")
				if method == "Same Tab":
					html = html.replace("__PARAMS__", "target=\"_parent\"")
				elif method == "New Tab":
					html = html.replace("__PARAMS__", "target=\"_blank\"")
				elif method == "New Window":
					var w = ProjectSettings.get_setting("display/window/size/window_width_override")
					if w <= 0:
						w = ProjectSettings.get_setting("display/window/size/viewport_width")
					var h = ProjectSettings.get_setting("display/window/size/window_height_override")
					if h <= 0:
						h = ProjectSettings.get_setting("display/window/size/viewport_height")
					html = html.replace("__PARAMS__", "onclick=\"window.open('__GAME_HTML__', '_blank', 'popup,innerWidth=" + str(w) + ",innerHeight=" + str(h) + "'); return false;\"")
				else:
					push_error("ERROR: invalid iframe breakout method")
				html = html.replace("__GAME_HTML__", export_path.get_file())
				html = html.replace("__TITLE__", ProjectSettings.get_setting("application/config/name"))
				var file = FileAccess.open(export_path.get_base_dir().path_join("index.html"), FileAccess.WRITE)
				file.store_string(html)
				file.close()

func _export_end() -> void:
	if exporting_web:
		var html := FileAccess.get_file_as_string(export_path)
		var pos = html.find("<script src=")
		html = html.insert(pos, "<script>" + EXTRA_SCRIPT + "</script>\n<script src=\"" + JS_FILE + "\"></script>\n")
		var file := FileAccess.open(export_path, FileAccess.WRITE)
		file.store_string(html)
		file.close()
		DirAccess.copy_absolute(plugin_path.path_join(JS_FILE), export_path.get_base_dir().path_join(JS_FILE))
	exporting_web = false

func _export_file(path: String, type: String, features: PackedStringArray) -> void:
	if path.begins_with(plugin_path):
		skip()

const EXTRA_SCRIPT = """
if (!window.SharedArrayBuffer) {
	document.getElementById('status').style.display = 'none';
	setTimeout(() => document.getElementById('status').style.display = '', 1500);
}
"""

const POPOUT_INDEX_HTML = """<doctype html>
<html>
<head>
<title>__TITLE__</title>
<style>
body {
	background-color: black;
}
div {
	margin-top: 40vh;
	text-align: center;
}
a {
	font-size: 18pt;
	color: #eaeaea;
	background-color: #3b3943;
	background-image: linear-gradient(to bottom, #403e48, #35333c);
	padding: 10px 15px;
	cursor: pointer;
	border-radius: 3px;
	text-decoration: none;
}
a:hover {
	background-color: #403e48;
	background-image: linear-gradient(to top, #403e48, #35333c);
}
</style>
</head>
<body>
<div><a href="__GAME_HTML__" __PARAMS__>Play __TITLE__</a></div>
</body>
</html>
"""
�1_�}�@tool
extends EditorPlugin

var export_plugin: EditorExportPlugin = null

func _enter_tree() -> void:
	var path: String = get_script().resource_path
	export_plugin = load(path.get_base_dir().path_join("coi_export_plugin.gd")).new()
	add_export_plugin(export_plugin)

func _exit_tree() -> void:
	remove_export_plugin(export_plugin)
	export_plugin = null
�#tɧX�|4���RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_wklnc �          PackedScene          	         names "         Control    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    Label    anchor_left    anchor_top    offset_left    offset_top    offset_right    offset_bottom    text    	   variants                        �?                        ?     ��     P�     �A     PA      Hello       node_count             nodes     4   ��������        ����                                                          ����                     	                  
               	      
                               conn_count              conns               node_paths              editable_instances              version             RSRC�ځb��#�GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[  @�o�0��[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://cd16u8lhu0llp"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 `���3������&�[remap]

path="res://.godot/exported/133200997/export-2a9725ce195a9960d0e7a251a59366de-example.scn"
x����(���list=Array[Dictionary]([])
�3�<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
R�՚��Q   ;{�1.   res://example.tscn�n�f!�E   res://icon.svg�C&"ECFG      application/config/name         Project    application/run/main_scene         res://example.tscn     application/config/features(   "         4.1    GL Compatibility       application/config/icon         res://icon.svg  #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility�,hz5�v=��