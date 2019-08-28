 (function($) {
  var _settings = {};
  var arrayObjClickPoint = new Array();
  var paragraphObj = {};
  $.fn.appendAttach = function(imgAddr) {
		document.getElementById(this[0].id + "_insertimage").classList.remove("wd-insertimage-active");
		addImageEle(_settings[this[0].id], imgAddr);
		if(!document.getElementById("wd_editImgWrap")) {
  addImgOptBox(_settings[this[0].id]);
		}
  }
  $.fn.setDisabled = function() {
		// 不可编辑
		var _tool = find(document.getElementById(this[0].id), "wd-toolbox");
		for(var i = 0; i < _tool.length; i++) {
  _tool[i].classList.add("wd-toolbox-default");
  if(find(_tool[i], "wd-file").length > 0) {
  find(_tool[i], "wd-file")[0].disabled = true;
  }
		}
		var _edit = find(document.getElementById(this[0].id), "wd-editeditbox");
		_edit[0].contentEditable = "false";
		var _editP = find(document.getElementById(this[0].id), "wd-editp");
		for(var j = 0; j < _editP.length; j++) {
  if(_editP[j].classList.contains("Img")) {
  _editP[j].classList.add("wd-toolbox-default");
  }
		}
  }
  $.fn.setEnabled = function() {
		// 可编辑
		var _tool = find(document.getElementById(this[0].id), "wd-toolbox");
		for(var i = 0; i < _tool.length; i++) {
  _tool[i].classList.remove("wd-toolbox-default");
  if(find(_tool[i], "wd-file").length > 0) {
  find(_tool[i], "wd-file")[0].disabled = false;
  }
		}
		var _edit = find(document.getElementById(this[0].id), "wd-editeditbox");
		_edit[0].contentEditable = "true";
		var _editP = find(document.getElementById(this[0].id), "wd-editp");
		for(var j = 0; j < _editP.length; j++) {
  if(_editP[j].classList.contains("Img")) {
  _editP[j].classList.remove("wd-toolbox-default");
  }
		}
  }
  $.fn.getContent = function() {
		var retFlag = false;
		var obj_p = find(document.getElementById("wd-editeditbox_" + this[0].id), "wd-editp");
		for(var j = 0; j < obj_p.length; j++) {
  if(getLastChildNode(obj_p[j]).innerHTML != "<br>" && getLastChildNode(obj_p[j]).innerHTML != "") {
  retFlag = true;
  }
		}
		if(retFlag) {
  // 获取带格式内容
  var imgOpt = find(document.getElementById("wd-editeditbox_" + this[0].id), "wd-editFileSingleOpt");
  for(var i = 0; i < imgOpt.length; i++) {
  imgOpt[i].style.display = "none";
  }
  return document.getElementById("wd-editeditbox_" + this[0].id).innerHTML;
		} else {
  return "";
		}
  };
  $.fn.getContentTxt = function() {
		// 获取纯文本内容
		var contentTxt = getSpeCont(this[0].id, "1");
		return contentTxt;
  };
  $.fn.getContentImg = function() {
		// 获取所有图片
		var contentTxt = getSpeCont(this[0].id, "2");
		return contentTxt;
  }
  $.fn.setContent = function(content, isAppendTo) {
  if(content != "") {
  var _id = this[0].id;
  if(isAppendTo) {
  document.getElementById("wd-editeditbox_" + this[0].id).innerHTML += content;
  scrollBottom(document.getElementById("wd-editeditbox_" + this[0].id));
  var obj_p = find(document.getElementById("wd-editeditbox_" + this[0].id), "wd-editp");
  moveEnd(obj_p[obj_p.length - 1]);
  } else {
  document.getElementById("wd-editeditbox_" + this[0].id).innerHTML = content;
  }
  if(!document.getElementById("wd_editImgWrap")) {
  addImgOptBox(_settings[this[0].id]);
  }
  
  // 添加事件
  var arrImg = find(document.getElementById("wd-editeditbox_" + this[0].id), "wd-editImgWrap");
  for(var i = 0; i < arrImg.length; i++) {
  arrImg[i].addEventListener("touchstart", function() {
                             if(!this.parentNode.classList.contains("wd-toolbox-default")) {
                             var opt = find(this, "wd-editFileSingleOpt")[0];
                             if(opt.style.display == "none") {
                             opt.style.display = "block";
                             } else {
                             opt.style.display = "none";
                             }
                             }
                             });
  // 上移
  var up = find(arrImg[i], "wd-editImgUp")[0];
  up.addEventListener('tap', function() {
                      moveImg(this.parentNode.parentNode, this, "up");
                      });
  // 下移
  var down = find(arrImg[i], "wd-editImgDown")[0];
  down.addEventListener('tap', function() {
                        moveImg(this.parentNode.parentNode, this, "down");
                        });
  // 修改
  var edit = find(arrImg[i], "wd-eidtImgEdit")[0];
  edit.addEventListener('tap', function() {
                        document.getElementById("wd_editBg").style.display = "block";
                        document.getElementById("wd_editBg").style.height = document.height;
                        document.getElementById("wd_editImgWrap").style.display = "block";
                        document.getElementById("wd_editImgWrap").setAttribute("rel", this.parentNode.previousSibling.id);
                        var _img = this.parentNode.previousSibling;
                        showImgOpt(_settings[_id], _img);
                        });
  // 删除
  var del = find(arrImg[i], "wd-eidtImgDel")[0];
  del.addEventListener('tap', function(e) {
                       remove(this.parentNode.parentNode.parentNode);
                       });
  }
		}
  };
  $.fn.wdEditStarter = function(objs) {
		// 鼠标抬起时记录选中信息
  var SupportsTouches = ("createTouch" in document),
  EndEvent = SupportsTouches ? "touchend" : "mouseup";
		document.addEventListener(EndEvent, function() {
                                  getWindowSelectObjs(objs);
                                  });
		var _this = this;
		// 默认值处理
		var defaults = {
  id: _this[0].id,
  toolbar: ['bold', 'italic', 'underline', 'insertimage'],
  width: "100%",
  height: "",
  clock: true,
  
  uploadOptions: {
  delUrl: getRequestAddressUrl("filedelete"),
  script: getRequestAddressUrl("fileupload"),
  totalSize: 0,
  addFiles: {},
  map_Files: {}
  }
		}
		var objs = $.extend(true, defaults, objs);
		_settings[this[0].id] = objs;
		// 加载工具条
		var toolDiv = document.createElement('div');
		toolDiv.className = "wd-edittoolbox";
		for(var i = 0; i < objs.toolbar.length; i++) {
  toolDiv.appendChild(addtool(objs, objs.toolbar[i]));
		}
		// 记录加载p的计数
		var recordpcount = document.createElement('input');
		recordpcount.id = "wd-recordpcount_" + objs.id;
		recordpcount.value = "0";
		recordpcount.type = "hidden";
		toolDiv.appendChild(recordpcount);
		_this[0].appendChild(toolDiv);
  
		// 加载文本编辑区
		var editDiv = document.createElement('div');
		editDiv.className = "wd-editeditbox";
		editDiv.contentEditable = "true";
		editDiv.id = "wd-editeditbox_" + objs.id;
		if(!objs.height) {
  editDiv.style.height = document.documentElement.clientHeight - pageY(toolDiv) - toolDiv.offsetHeight - 3 + "px";
		} else {
  editDiv.style.height = objs.height + "px";
		}
		editDiv.appendChild(addp(objs, editDiv));
		if(objs.width.indexOf('%') == -1) editDiv.style.width = objs.width + "px";
		else editDiv.style.width = objs.width;
		// 文本编辑器被点击时光标默认在最后一个p上
		editDiv.addEventListener('tap', function(e) {
                                 var _this = this;
                                 initCont(objs);
                                 setArrayObjClickPoint();
                                 
                                 var target = e.target;
                                 if(document.getElementById("edit_cont") && target.id != document.getElementById("edit_cont").getAttribute("rel") && document.getElementById("edit_cont").length > 0) {
                                 document.getElementById("edit_cont").style.display = "none";
                                 document.getElementById(objs.id).appendChild(document.getElementById("edit_cont"));
                                 }
                                 });
  
		editDiv.addEventListener("keydown", function(e) {
                                 if(e && e.keyCode == 13) { // 回车
                                 e.preventDefault(false);
                                 var sel = window.getSelection();
                                 var parentStart = getParentNode(sel.anchorNode);
                                 var allLength = parentStart.innerText.length; // 当前p的字符总长度
                                 if((sel.anchorNode.className == "wd-editp" && sel.anchorNode.innerHTML == "<br>") || (sel.anchorNode.nodeValue == "<br>")) {
                                 allLength = 0;
                                 }
                                 var mouseLength = getMouseLen(parentStart); // 鼠标所在位置
                                 
                                 // 如果鼠标位置长度等于所有子元素长度则创建一个新P
                                 paragraphObj["curObj"] = parentStart;
                                 var curObj = paragraphObj.curObj;
                                 if(mouseLength == allLength) {
                                 var parea = addp(objs);
                                 if(curObj.className.indexOf("wd-editp") != -1) {
                                 insertAfter(parea, curObj);
                                 } else if(getParentNode(curObj) && getParentNode(curObj).className.indexOf("wd-editp") != -1) {
                                 insertBefore(parea, getParentNode(curObj));
                                 } else {
                                 document.getElementById("wd-editeditbox_" + objs.id).appendChild(parea);
                                 }
                                 paragraphObj["curObj"] = parea;
                                 moveFocus(parea);
                                 
                                 var arrStyle = getFontStyle(objs);
                                 $.each(arrStyle, function(i) {
                                        addFontStyle(objs, arrStyle[i], parea);
                                        });
                                 } else {
                                 fuseObj(objs, mouseLength);
                                 }
                                 } else if(e && e.keyCode == 8 || e.keyCode == 46) { // 退格和删除
                                 // 最后一个p不删除
                                 var sel = window.getSelection();
                                 var _this = getParentNode(sel.anchorNode);
                                 if((sel.anchorNode.className == "wd-editp" && (sel.anchorNode.innerHTML == "<br>" || sel.anchorNode.innerHTML == "")) || (sel.anchorNode.nodeValue == "<br>" && sel.anchorNode.nodeValue == "")) {
                                 var allP = find(document.getElementById(objs.id), 'p');
                                 var allPCount = allP.length; // 所有的p
                                 var thisIndex = index(_this); // 当前p的位置
                                 if(allPCount >= 1) {
                                 e.preventDefault(false);
                                 if(e.keyCode == 8) { //退格光标定位到上一个p最后
                                 if(prev(_this) && prev(_this).className.indexOf("Img") == -1) {
                                 moveEnd(prev(_this));
                                 remove(_this);
                                 }
                                 } else { // 删除光标定位到下一个第一个
                                 if(next(_this) && next(_this).className.indexOf("Img") == -1) {
                                 if(thisIndex < allPCount) { // 删除的不是最后一个
                                 moveFocus(next(_this));
                                 } else {
                                 moveEnd(prev(_this));
                                 }
                                 remove(_this);
                                 }
                                 }
                                 }
                                 } else if(arrayObjClickPoint.length > 0) {
                                 var startObj = getParentNode(arrayObjClickPoint[0].startObjNode);
                                 var endObj = getParentNode(arrayObjClickPoint[0].endObjNode);
                                 if(startObj == endObj) {
                                 var parentStart = getParentNode(window.getSelection().anchorNode);
                                 if(parentStart && parentStart.className.indexOf("Img") != -1) {
                                 e.preventDefault(false);
                                 moveFocus(next(parentStart));
                                 remove(parentStart);
                                 } else {
                                 if(e.keyCode == 8) {
                                 if(window.getSelection().anchorOffset == 0) {
                                 var preObj = prev(_this);
                                 if(preObj && preObj.className.indexOf("Img") == -1) {
                                 e.preventDefault(false);
                                 moveEnd(preObj);
                                 var childNode = getLastChildNode(preObj);
                                 var nextChildNode = getLastChildNode(_this);
                                 if(childNode.innerHTML == "<br>" && nextChildNode.innerHTML != "<br>" && nextChildNode.innerHTML != "") {
                                 childNode.innerHTML = "";
                                 }
                                 var iCount = nextChildNode.childNodes.length;
                                 for(var i = 0; i < iCount; i++) {
                                 childNode.appendChild(nextChildNode.childNodes[0]);
                                 }
                                 getWindowSelectObjs(objs);
                                 paragraphObj.curObj = preObj;
                                 remove(_this);
                                 } else if(preObj && preObj.className.indexOf("Img") != -1) {
                                 e.preventDefault(false);
                                 }
                                 }
                                 } else {
                                 var nextObj = next(_this);
                                 var allLength = parentStart.innerText.length;
                                 if(window.getSelection().anchorOffset == allLength && nextObj.className.indexOf("Img") != -1) {
                                 e.preventDefault(false);
                                 }
                                 if(nextObj && nextObj.className.indexOf("Img") == -1 && nextObj && nextObj.childNodes.length > 0 && !window.getSelection().toString()) {
                                 if(window.getSelection().anchorOffset == allLength) {
                                 e.preventDefault(false);
                                 }
                                 var childNode = getLastChildNode(_this);
                                 var nextChildNode = getLastChildNode(nextObj);
                                 if(childNode.innerHTML == "<br>" && nextChildNode.innerHTML != "<br>" && nextChildNode.innerHTML != "") {
                                 childNode.innerHTML = "";
                                 }
                                 var iCount = nextChildNode.childNodes.length;
                                 for(var i = 0; i < iCount; i++) {
                                 childNode.appendChild(nextChildNode.childNodes[0]);
                                 }
                                 remove(nextObj);
                                 }
                                 }
                                 }
                                 }
                                 }
                                 }
                                 var obj_p = find(document.getElementById(objs.id), "wd-editp");
                                 if(obj_p.length == 0) {
                                 var _div = document.getElementById("wd-editeditbox_" + objs.id);
                                 var _text = "";
                                 if(_div.innerHTML != "<br>" && _div.innerHTML != "") {
                                 _text = _div.innerHTML;
                                 }
                                 _div.innerHTML = "";
                                 var _addp = addp(objs);
                                 if(_text) {
                                 _addp.innerHTML = _text;
                                 }
                                 _div.appendChild(_addp);
                                 moveFocus(_addp);
                                 paragraphObj["curObj"] = _addp;
                                 var arrStyle = getFontStyle(objs);
                                 $.each(arrStyle, function(i) {
                                        addFontStyle(objs, arrStyle[i], _addp);
                                        });
                                 }
                                 });
  
		_this[0].appendChild(editDiv);
  };
  
  // 获取光标位置信息
  function setArrayObjClickPoint() {
		var selectObj = window.getSelection();
		if(selectObj.anchorNode) {
  var startObj = selectObj.anchorNode.parentNode;
  var startObjNode = selectObj.anchorNode;
  var startObjPreObj = (selectObj.anchorNode.previousElementSibling) ? selectObj.anchorNode.previousElementSibling : selectObj.anchorNode.previousSibling;
  var startObjNextObj = (selectObj.anchorNode.nextElementSibling) ? selectObj.anchorNode.nextElementSibling : selectObj.anchorNode.nextSibling;
  var endObj = selectObj.focusNode.parentNode;
  var endObjPreObj = (selectObj.focusNode.previousElementSibling) ? selectObj.focusNode.previousElementSibling : selectObj.focusNode.previousSibling;
  var endObjNextObj = (selectObj.focusNode.nextElementSibling) ? selectObj.focusNode.nextElementSibling : selectObj.focusNode.nextSibling;
  var endObjNode = selectObj.focusNode;
  arrayObjClickPoint.pop(arrayObjClickPoint.length);
  arrayObjClickPoint.push({ // 记录选择对象待处理信息
                          "startObjBox": startObj, // 选中文本起始对象（P）
                          "endObjBox": endObj, // 选中文本终止对象（P）
                          "selectText": selectObj.toString(),
                          "startObjPreObj": startObjPreObj, // 选中对象前一个对象（strong）
                          "startObjNextObj": startObjNextObj, // 选中对象后一个对象（strong）
                          "start": selectObj.anchorOffset, // 选中文本在起始对象中的位置
                          "end": selectObj.focusOffset, // 选中文本在终止对象中的位置
                          "startObjNode": startObjNode, // 当前选中文本对象(strong)
                          "endObjNode": endObjNode
                          });
		}
  }
  
  // 加载编辑区p
  function addp(objs) {
		var editp = document.createElement('p');
		editp.className = "wd-editp";
		//$(editp).attr("contenteditable", "true");
		editp.name = document.getElementById("wd-recordpcount_" + objs.id).value;
		editp.innerHTML = '<br>';
  
		document.getElementById("wd-recordpcount_" + objs.id).value = parseInt(document.getElementById("wd-recordpcount_" + objs.id).value) + 1; // 设置下一个p的id
		return editp;
  };
  
  // 获取光标所在位置
  function getMouseLen(obj) {
		var mouseLength = 0;
		var lastChild = getLastChildNode(obj);
		var iCount = lastChild.childNodes.length; // 当前操作p的所有子对象数量
		if(obj.childNodes.length > 0) {
  for(var i = 0; i < iCount; i++) {
  // 如果是当前子元素是回车元素
  if(lastChild.childNodes[i] == window.getSelection().anchorNode) {
  mouseLength = mouseLength + window.getSelection().anchorOffset;
  break;
  } else { // 如果不是叠加子元素长度
  if(window.getSelection().anchorOffset != 0) {
  var temp = getElementText(lastChild.childNodes[i]);
  if(temp && lastChild.innerHTML != "<br>" && lastChild.innerHTML != "") {
  mouseLength = mouseLength + temp.length;
  }
  }
  }
  }
		}
		return mouseLength;
  }
  
  // 融合对象
  function fuseObj(objs, mouseLength, tempObj) {
		var sel = window.getSelection();
		var curObj = paragraphObj.curObj;
		var selectedText = "";
		if(sel.anchorNode.wholeText) {
  selectedText = sel.anchorNode.wholeText;
		} else {
  selectedText = getLastChildNode(sel.anchorNode).innerText;
		}
		var parea = addp(objs);
		// 获取回车后对象集合
		if(selectedText) {
  var lastText = selectedText.substring(mouseLength, selectedText.length);
  var _obj = getLastChildNode(curObj);
  _obj.innerHTML = selectedText.substring(0, mouseLength);
  if(_obj.innerHTML == "") {
  _obj.innerHTML = "<br>";
  }
  parea.innerHTML = lastText;
		}
		if(tempObj) {
  insertAfter(parea, tempObj);
  insertAfter(tempObj, curObj);
		} else {
  insertAfter(parea, curObj);
		}
		moveFocus(parea);
		paragraphObj["curObj"] = parea;
		var arrStyle = getFontStyle(objs);
		$.each(arrStyle, function(i) {
               addFontStyle(objs, arrStyle[i], parea);
               });
  }
  
  // 获取当前对象信息
  function getWindowSelectObjs(objs) {
		initCont(objs);
		if(window.getSelection) {
  var selectObj = window.getSelection();
  if(selectObj.anchorNode) {
  var startObj = selectObj.anchorNode.parentNode;
  var startObjNode = selectObj.anchorNode;
  
  if(getParentNode(startObjNode) && getParentNode(startObjNode).className.indexOf("wd-editp") != -1 && getParentNode(startObjNode).className == "wd-editp") {
  paragraphObj["curObj"] = getParentNode(startObjNode);
  }
  var arrStyle = getFontStyle(objs);
  var arrNode = setFontStyle(objs);
  for(var i = 0; i < arrStyle.length; i++) {
  if(!contains(arrNode, arrStyle[i])) {
  if(arrStyle[i] == "b") {
  document.getElementById(objs.id + "_B").classList.remove("wd-edittoolbox-active");
  }
  if(arrStyle[i] == "i") {
  document.getElementById(objs.id + "_I").classList.remove("wd-edittoolbox-active");
  }
  if(arrStyle[i] == "u") {
  document.getElementById(objs.id + "_U").classList.remove("wd-edittoolbox-active");
  }
  }
  }
  } else {
  initCursorPos(objs);
  }
		}
  };
  
  // 添加处理的结果到p上
  function addAndRemObjOrHtml(remObj, addStr, flg, objs) {
		if(flg) {
  var curObj = paragraphObj.curObj;
  if(curObj && (curObj.innerHTML == "<br>" || curObj.innerHTML == "" || getLastChildNode(curObj).innerHTML == "<br>" || getLastChildNode(curObj).innerHTML == "")) {
  if(find(addStr, "img").length > 0) {
  if(next(paragraphObj.curObj)) {
  paragraphObj.curObj = addStr[0];
  insertAfter(addStr, remObj);
  remove(remObj);
  moveFocus(next(paragraphObj.curObj));
  } else {
  insertBefore(addStr, remObj);
  }
  }
  } else {
  if(find(addStr, "img").length > 0) {
  var allLength = remObj.innerText.length; // 当前p的字符总长度
  var mouseLength = getMouseLen(remObj); // 鼠标所在位置
  if(mouseLength == allLength) {
  if(!next(paragraphObj.curObj)) {
  var addP = addp(objs);
  insertAfter(addStr, remObj);
  insertAfter(addP, addStr);
  moveFocus(addP);
  paragraphObj["curObj"] = addP;
  } else {
  insertAfter(addStr, remObj);
  moveFocus(paragraphObj.newObj);
  paragraphObj["curObj"] = paragraphObj.newObj;
  paragraphObj["newObj"] = "";
  }
  } else if(mouseLength == 0) {
  insertBefore(addStr, remObj);
  } else {
  fuseObj(objs, mouseLength, addStr);
  }
  } else {
  insertAfter(addStr, remObj);
  remove(remObj);
  }
  }
		} else {
  return addStr;
		}
  };
  
  // 获取对象的值
  function getElementText(obj) {
		return(obj.innerHTML) ? obj.innerHTML : obj.nodeValue;
  };
  
  // 获取父节点,p或者p下一个
  function getParentNode(present) {
		if(present == null) {
  return null;
		}
		if(present.className && present.className.indexOf("wd-editp") != -1) {
  return present;
		} else {
  return getParentNode(present.parentNode);
		}
  };
  
  // 获取子节点
  function getLastChildNode(present) {
		if(present == null) {
  return null;
		}
		var childNode = present.childNodes;
		if(childNode.length > 0 && childNode[0].childNodes.length > 0) {
  return getLastChildNode(childNode[0]);
		} else if(childNode.length > 0) {
  return childNode[0].parentNode;
		} else {
  return present;
		}
  }
  
  // 获取p的最后一个对象
  function getLastNode(present) {
		return present.childNodes[present.childNodes.length - 1];
  };
  
  // 批量上传
  function uploadFiles(objs) {
		for(var key in objs.uploadOptions.map_Files) {
  if(objs.uploadOptions.map_Files[key]) {
  upload(objs, objs.uploadOptions.map_Files[key], key);
  }
		}
  }
  
  // 上传
  function upload(objs, file, key) {
		var xhr = new XMLHttpRequest();
		xhr.open("POST", objs.uploadOptions.script, false);
		var formData = new FormData();
		formData.append("files", file);
		xhr.onreadystatechange = function() {
  if(xhr.readyState == 4 && xhr.status == 200) {
  // 从服务器的response获得数据
  var obj = $.parseJSON(xhr.response);
  var _files = obj.msgObj;
  for(var i = 0; i < _files.length; i++) {
  if(obj.successFlg == true) {
  objs.uploadOptions.addFiles[_files[i].fileId] = _files[i];
  if(objs.uploadOptions.map_Files) {
  remove(find(document.getElementById("" + key), "wd-editFileSingleOpt")[0]);
  find(document.getElementById("" + key), "wd_editFileSuccess").style.display = "block";
  objs.uploadOptions.map_Files[key] = "";
  }
  }
  }
  }
		}
		xhr.send(formData);
  }
  
  // 添加image对象到编辑区
  function addImageEle(objs, path) {
		var img_str = document.createElement("span");
		var addFiles = objs.uploadOptions.addFiles;
		//		for (var key in addFiles) {
		var imgWrap = document.createElement("span");
		imgWrap.className = "wd-editImgWrap";
  
		var img = document.createElement("img");
		img.id = newGuid();
		img.src = path;
		//			img.title = addFiles[key].fileName;
		//			img.alt = addFiles[key].fileName;
		img.style.maxWidth = (document.getElementById(objs.id).offsetWidth - 16) + "px";
		imgWrap.appendChild(img); // 当前挪动
  
		var imgOpt = document.createElement("span");
		imgOpt.className = "wd-editFileSingleOpt";
  
		var del = document.createElement("span");
		del.className = "wd-eidtImgDel";
		imgOpt.appendChild(del);
  
		var edit = document.createElement("span");
		edit.className = "wd-eidtImgEdit";
		imgOpt.appendChild(edit);
		edit.addEventListener('tap', function() {
                              document.getElementById("wd_editBg").style.display = "block";
                              document.getElementById("wd_editBg").style.height = document.height;
                              document.getElementById("wd_editImgWrap").style.display = "block";
                              document.getElementById("wd_editImgWrap").setAttribute("rel", this.parentNode.previousSibling.id);
                              var _img = this.parentNode.previousSibling;
                              showImgOpt(objs, _img);
                              });
  
		var down = document.createElement("span");
		down.className = "wd-editImgDown";
		down.addEventListener('tap', function() {
                              moveImg(imgWrap, this, "down");
                              });
		imgOpt.appendChild(down);
  
		var up = document.createElement("span");
		up.className = "wd-editImgUp";
		up.addEventListener('tap', function() {
                            moveImg(imgWrap, this, "up");
                            });
		imgOpt.appendChild(up);
		imgWrap.appendChild(imgOpt);
  
		imgWrap.addEventListener("touchstart", function() {
                                 var opt = find(this.parentNode, "wd-editFileSingleOpt")[0];
                                 if(opt.style.display == "none") {
                                 opt.style.display = "block";
                                 } else {
                                 opt.style.display = "none";
                                 }
                                 });
  
		var imgP = addp(objs);
		imgP.classList.add("Img");
		imgP.setAttribute("contenteditable", "false");
		imgP.innerHTML = "";
		imgP.appendChild(imgWrap);
  
		del.addEventListener('tap', function(e) {
                             remove(imgP);
                             });
  
		img_str.appendChild(imgP);
		var curObj = paragraphObj.curObj;
		if(curObj && curObj.innerHTML != "<br>" && curObj.innerHTML != "" && getLastChildNode(curObj).innerHTML != "<br>" && getLastChildNode(curObj).innerHTML != "") {
  if(next(paragraphObj.curObj)) {
  paragraphObj["newObj"] = next(paragraphObj.curObj);
  }
		}
		addAndRemObjOrHtml(paragraphObj.curObj, img_str.children[0], true, objs);
		//		}
  }
  
  // 图片移动
  function moveImg(moveImg, moveToImg, moveDir) {
		var toImg;
		var curImg = moveImg.parentNode;
		if(moveDir == "up") {
  var obj = getParentNode(moveToImg);
  var prevAllObj = prevAll(obj, "Img");
  for(var i = 0; i < prevAllObj.length; i++) {
  if(prevAllObj[i].classList.contains("Img")) {
  toImg = prevAllObj[i];
  break;
  }
  }
		} else {
  var obj = getParentNode(moveToImg);
  var nextAllObj = nextAll(obj, "Img");
  for(var i = 0; i < nextAllObj.length; i++) {
  if(nextAllObj[i].classList.contains("Img")) {
  toImg = nextAllObj[i];
  break;
  }
  }
		}
		if(toImg) {
  var tempObj = find(toImg, "wd-editImgWrap"); // 被挪动的
  toImg.appendChild(moveImg);
  curImg.appendChild(tempObj[0]);
		}
  }
  
  // 图片操作区位置
  function showImgOpt(objs, obj) {
		var _left = obj.offsetLeft;
		var _top = obj.offsetTop;
		var width = obj.width;
		var height = obj.height;
  
		document.getElementById("wd_editImgWidth").value = obj.width;
		document.getElementById("wd_editImgHeight").value = obj.height;
		if(obj.border) {
  document.getElementById("wd_editImgBorder").value = obj.border;
		} else {
  document.getElementById("wd_editImgBorder").value = 0;
		}
		if(obj.vspace) {
  document.getElementById("wd_editImgPadding").value = obj.vspace;
		} else {
  document.getElementById("wd_editImgPadding").value = 0;
		}
		document.getElementById("wd_editImgDesc").value = obj.alt;
  }
  
  // 设置图片
  function addImgOptBox(objs) {
		// 遮罩层背景
		var editBg = document.createElement("div");
		editBg.id = "wd_editBg";
		editBg.className = "wd-editBg";
		document.body.appendChild(editBg);
  
		var editImgWrap = document.createElement("div");
		// 标题
		editImgWrap.id = "wd_editImgWrap";
		editImgWrap.className = "wd-editChosenWrap";
		if(document.documentElement.clientWidth < 400) {
  var _width = document.documentElement.clientWidth - 40;
  editImgWrap.style.width = _width + "px";
  editImgWrap.style.marginLeft = -(_width / 2) + "px";
		} else {
  editImgWrap.style.width = "400px";
  editImgWrap.style.marginLeft = "-200px";
		}
		if(document.documentElement.clientHeight < 360) {
  var _height = document.documentElement.clientHeight - 100;
  editImgWrap.style.height = _height + "px";
  editImgWrap.style.marginTop = -(_height / 2) + "px";
		} else {
  editImgWrap.style.height = "360px";
  editImgWrap.style.marginTop = "-180px";
		}
		var editImgTop = document.createElement("div");
		editImgTop.className = "wd-editChosenTop";
		var editImgTit = document.createElement("span");
		editImgTit.className = "wd-editChosenTit";
		editImgTit.innerHTML = getMsgByLanguage("Picture-set");
		editImgTop.appendChild(editImgTit);
		var editImgClose = document.createElement("span");
		editImgClose.className = "wd-editChosenClose";
		editImgClose.addEventListener('tap', function() {
                                      closeImgOpt(objs);
                                      });
		editImgTop.appendChild(editImgClose);
		editImgWrap.appendChild(editImgTop);
		// 内容
		// 设置
		var editImgPro = document.createElement("div");
		editImgPro.id = "wd_editFileWrap";
		editImgPro.className = "wd-editFileWrap wd-editImg";
		editImgPro.style.height = (parseInt(editImgWrap.style.height) - 80) + "px";
		var _table = document.createElement("table");
		_table.className = "wd-editTable";
  
		var _trSize = document.createElement("tr");
		var _thSize = document.createElement("th");
		_thSize.innerHTML = getMsgByLanguage("Size");
		_trSize.appendChild(_thSize);
		var _tdSize = document.createElement("td");
		var span1 = document.createElement("span");
		span1.innerHTML = getMsgByLanguage("Width");
		_tdSize.appendChild(span1);
		var inputWidth = document.createElement("input");
		inputWidth.id = "wd_editImgWidth";
		inputWidth.className = "wd-editInput wd-eidtWidth46";
		_tdSize.appendChild(inputWidth);
		var span2 = document.createElement("span");
		span2.innerHTML = "px&nbsp;&nbsp;"+getMsgByLanguage('Height');
		span2.className = "wd-eidtUnit";
		_tdSize.appendChild(span2);
		var inputHeight = document.createElement("input");
		inputHeight.id = "wd_editImgHeight";
		inputHeight.className = "wd-editInput wd-eidtWidth46";
		_tdSize.appendChild(inputHeight);
		var span3 = document.createElement("span");
		span3.innerHTML = "px";
		span3.className = "wd-eidtUnit";
		_tdSize.appendChild(span3);
		_trSize.appendChild(_tdSize);
		_table.appendChild(_trSize);
  
		var _trBorder = document.createElement("tr");
		var _thBorder = document.createElement("th");
		_thBorder.innerHTML = getMsgByLanguage('Frame');
		_trBorder.appendChild(_thBorder);
		var _tdBorder = document.createElement("td");
		var inputBorder = document.createElement("input");
		inputBorder.id = "wd_editImgBorder";
		inputBorder.className = "wd-editInput";
		_tdBorder.appendChild(inputBorder);
		var span4 = document.createElement("span");
		span4.innerHTML = "px";
		span4.className = "wd-eidtUnit";
		_tdBorder.appendChild(span4);
		_trBorder.appendChild(_tdBorder);
		_table.appendChild(_trBorder);
  
		var _trPadding = document.createElement("tr");
		var _thPadding = document.createElement("th");
		_thPadding.innerHTML = getMsgByLanguage('Margin');
		_trPadding.appendChild(_thPadding);
		var _tdPadding = document.createElement("td");
		var inputPadding = document.createElement("input");
		inputPadding.id = "wd_editImgPadding";
		inputPadding.className = "wd-editInput";
		_tdPadding.appendChild(inputPadding);
		var span5 = document.createElement("span");
		span5.innerHTML = "px";
		span5.className = "wd-eidtUnit";
		_tdPadding.appendChild(span5);
		_trPadding.appendChild(_tdPadding);
		_table.appendChild(_trPadding);
  
		var _trDesc = document.createElement("tr");
		var _thDesc = document.createElement("th");
		_thDesc.innerHTML = getMsgByLanguage('Describe');
		_trDesc.appendChild(_thDesc);
		var _tdDesc = document.createElement("td");
		var inputDesc = document.createElement("input");
		inputDesc.id = "wd_editImgDesc";
		inputDesc.className = "wd-editInput";
		_tdDesc.appendChild(inputDesc);
		_trDesc.appendChild(_tdDesc);
		_table.appendChild(_trDesc);
  
		editImgPro.appendChild(_table);
		editImgWrap.appendChild(editImgPro);
		// 操作区
		var editImgBottom = document.createElement("div");
		editImgBottom.className = "wd-editChosenBottom";
		var editImg_qd = document.createElement("input");
		editImg_qd.type = "button";
		editImg_qd.className = "wd-editChosenBtn";
		editImg_qd.value = getMsgByLanguage('Ok');
		editImg_qd.addEventListener('tap', function() {
                                    setImgOpt(objs);
                                    });
		editImg_qd.addEventListener('touchend', function() {
                                    setImgOpt(objs);
                                    });
		editImgBottom.appendChild(editImg_qd);
		var editImg_qx = document.createElement("input");
		editImg_qx.type = "button";
		editImg_qx.className = "wd-editChosenBtn";
		editImg_qx.value = getMsgByLanguage('Cancel');
		editImg_qx.addEventListener('tap', function() {
                                    closeImgOpt(objs);
                                    });
		editImg_qx.addEventListener('touchend', function() {
                                    closeImgOpt(objs);
                                    });
		editImgBottom.appendChild(editImg_qx);
		editImgWrap.appendChild(editImgBottom);
  
		document.body.appendChild(editImgWrap);
  }
  
  // 设置图片-确定
  function setImgOpt(objs) {
		var id = document.getElementById("wd_editImgWrap").getAttribute("rel");
		var _width = document.getElementById("wd_editImgWidth").value;
		if(_width) {
  document.getElementById(id).style.width = _width + "px";
  document.getElementById(id).style.maxWidth = _width + "px";
  document.getElementById(id).nextSibling.style.width = parseInt(_width) + "px";
		}
		var _height = document.getElementById("wd_editImgHeight").value;
		if(_height) {
  document.getElementById(id).style.height = _height + "px";
		}
		var border = document.getElementById("wd_editImgBorder").value;
		document.getElementById(id).style.border = border + "px solid";
		document.getElementById(id).setAttribute("border", border);
		var space = document.getElementById("wd_editImgPadding").value;
		document.getElementById(id).setAttribute("alt", document.getElementById("wd_editImgDesc").value);
		if(space) {
  document.getElementById(id).setAttribute("vspace", space);
  document.getElementById(id).setAttribute("hspace", space);
  if(_width){
  document.getElementById(id).style.maxWidth = (_width - 2 * space) + "px";
  }else{
  document.getElementById(id).style.maxWidth = (document.getElementById(objs.id).offsetWidth - 16 - 2 * space) + "px";
  }
  document.getElementById(id).nextSibling.style.marginTop = space + "px";
  document.getElementById(id).nextSibling.style.marginLeft = space + "px";
		}
		closeImgOpt(objs);
  }
  
  // 设置图片-关闭
  function closeImgOpt(objs) {
		document.getElementById("wd_editBg").style.display = "none";
		document.getElementById("wd_editImgWrap").style.display = "none";
  }
  
  // 获取操作节点name（strong、i、u、text）
  function getNodeName(obj) {
		return obj.nodeName.toLowerCase().replace('#', '');
  };
  
  // 是否包含
  function contains(arr, str) {
		var flag = false;
		$.each(arr, function(i) {
               if(arr[i] == str) {
               flag = true;
               return false;
               }
               })
		return flag;
  }
  
  // 定位光标到对象最后
  function moveEnd(obj) {
		if(obj) {
  if(window.getSelection) { //ie11 10 9 ff safari
  obj.focus(); //解决ff不获取焦点无法定位问题
  var range = window.getSelection(); //创建range
  range.selectAllChildren(obj); //range 选择obj下所有子内容
  range.collapseToEnd(); //光标移至最后
  } else if(document.selection) { //ie10 9 8 7 6 5
  var range = document.selection.createRange(); //创建选择对象
  range.moveToElementText(obj); //range定位到obj
  range.collapse(false); //光标移至最后
  range.select();
  }
		}
  };
  
  // 光标定位到对象开始
  function moveFocus(obj) {
		if(obj) {
  if(window.getSelection) { //ie11 10 9 ff safari
  obj.focus(); //解决ff不获取焦点无法定位问题
  var range = window.getSelection(); //创建range
  if(range.rangeCount != 0) {
  range.selectAllChildren(obj); //range 选择obj下所有子内容
  range.collapseToStart(); //光标移至开始
  }
  } else if(document.selection) { //ie10 9 8 7 6 5
  var range = document.selection.createRange(); //创建选择对象
  range.moveToElementText(obj); //range定位到obj
  range.collapse(true); //光标移至开始
  range.select();
  }
		}
  }
  
  // 获取已选择样式
  function getFontStyle(objs) {
		var arrStyle = [];
		var fontStyles = document.getElementById(objs.id).querySelectorAll(".wd-toolbox");
		mui.each(fontStyles, function(i) {
                 if(fontStyles[i].classList.contains("wd-edittoolbox-active")) {
                 var node = fontStyles[i].getAttribute("rel");
                 arrStyle.push(node);
                 }
                 });
		return arrStyle;
  }
  
  // 设置已有样式
  function setFontStyle(objs, curObj, arrNode) {
		if(!curObj) {
  curObj = paragraphObj.curObj;
  arrNode = [];
		}
		if(curObj && curObj.childNodes.length != 0) {
  var childNode = curObj.childNodes[0];
  var nodeName = getNodeName(curObj.childNodes[0]);
  if(nodeName == "b") {
  arrNode.push("b");
  document.getElementById(objs.id + "_B").classList.add("wd-edittoolbox-active");
  } else if(nodeName == "i") {
  arrNode.push("i");
  document.getElementById(objs.id + "_I").classList.add("wd-edittoolbox-active");
  } else if(nodeName == "u") {
  arrNode.push("u");
  document.getElementById(objs.id + "_U").classList.add("wd-edittoolbox-active");
  }
  
  if(getNodeName(childNode) != "text" && curObj.innerHTML != "<br>" && curObj.innerHTML != "") {
  setFontStyle(objs, childNode, arrNode);
  } else {
  return arrNode;
  }
		} else {
  arrNode = getFontStyle(objs);
		}
		return arrNode;
  }
  
  // 工具栏操作
  function addActiveClass(objs, obj, fontType) {
		if(!obj.classList.contains("wd-toolbox-default")) {
  initCursorPos(objs);
  if(obj.classList.contains("wd-edittoolbox-active")) {
  obj.classList.remove("wd-edittoolbox-active");
  removeFontStyle(objs, fontType);
  } else {
  obj.classList.add("wd-edittoolbox-active");
  addFontStyle(objs, fontType);
  }
		}
  }
  
  // 添加字体样式
  function addFontStyle(objs, fontType, curObj) {
		if(!curObj) {
  curObj = paragraphObj.curObj; // 当前待操作对象
		}
		if(fontType == "b") {
  var strong = document.createElement("b");
  strong.appendChild(curObj.childNodes[0]);
  curObj.appendChild(strong);
		}
		if(fontType == "i") {
  var em = document.createElement("i");
  em.appendChild(curObj.childNodes[0]);
  curObj.appendChild(em);
		}
		if(fontType == "u") {
  var u = document.createElement("u");
  u.appendChild(curObj.childNodes[0]);
  curObj.appendChild(u);
		}
  };
  
  // 移除字体样式
  function removeFontStyle(objs, fontType, curObj) {
		if(!curObj) {
  curObj = paragraphObj.curObj;
		}
		var childNode = curObj.childNodes[0];
		var nodeName = getNodeName(curObj.childNodes[0]);
		if((fontType == "b" && nodeName == "b") || (fontType == "i" && nodeName == "i") || (fontType == "u" && nodeName == "u") || curObj.innerHTML == "<br>" || curObj.innerHTML == "") {
  if(curObj.innerHTML != "<br>" && curObj.innerHTML != "") {
  var _nodeLen = childNode.childNodes.length;
  for(var i = 0; i < _nodeLen; i++) {
  curObj.appendChild(childNode.childNodes[0]);
  }
  curObj.removeChild(childNode);
  } else if(curObj.innerHTML == "<br>" || curObj.innerHTML == "") {
  var _preObj = prev(curObj);
  var _nextObj = next(curObj);
  remove(curObj);
  var _addp = addp(objs);
  if(_preObj) {
  insertAfter(_addp, _preObj);
  } else if(_nextObj) {
  insertBefore(_addp, _nextObj);
  } else {
  var _div = document.getElementById("wd-editeditbox_" + objs.id);
  _div.appendChild(_addp);
  }
  var arrStyle = getFontStyle(objs);
  $.each(arrStyle, function(i) {
         addFontStyle(objs, arrStyle[i], _addp);
         });
  paragraphObj["curObj"] = _addp;
  moveFocus(_addp);
  }
  return false;
		} else {
  if(getNodeName(childNode) != "text") {
  removeFontStyle(objs, fontType, childNode);
  } else {
  return false;
  }
		}
  };
  
  // 设置光标初始位置
  function initCursorPos(objs, flag) {
		var obj_p = find(document.getElementById(objs.id), "wd-editp");
		if(!paragraphObj.curObj) {
  paragraphObj["curObj"] = obj_p[obj_p.length - 1];
  if(!flag) {
  moveEnd(obj_p[obj_p.length - 1]);
  }
		}
  }
  
  // 删除完初始化内容
  function initCont(objs) {
		var obj_p = find(document.getElementById(objs.id), "wd-editp");
		if(obj_p.length == 0) {
  var _div = document.getElementById("wd-editeditbox_" + objs.id);
  _div.innerHTML = "";
  var _addp = addp(objs);
  _div.appendChild(_addp);
  paragraphObj["curObj"] = _addp;
  var arrStyle = getFontStyle(objs);
  $.each(arrStyle, function(i) {
         addFontStyle(objs, arrStyle[i], _addp);
         });
		}
  }
  
  // 获取内容
  function getSpeCont(id, spetype) {
		var cont = "";
		var childNodes = document.getElementById("wd-editeditbox_" + id).childNodes;
		for(var i = 0; i < childNodes.length; i++) {
  var _node = childNodes[i];
  if(spetype == "1") {
  if(!_node.classList.contains("Img")) {
  if(_node.innerHTML != "<br>" && _node.innerHTML != "") {
  cont = cont + _node.innerText;
  }
  }
  } else if(spetype == "2") {
  if(_node.classList.contains("Img")) {
  if(cont) {
  cont = cont + ",";
  }
  var _img = find(_node, "img");
  cont = cont + _img[0].src;
  }
  }
		}
		return cont;
  };
  
  // 加载工具条
  function addtool(objs, toolname) {
		var obj = document.createElement('div');
		switch(toolname) {
  case "bold":
  obj.className = "wd-toolbox wd-bold";
  obj.id = objs.id + "_B";
  obj.innerHTML = "B";
  obj.title = getMsgByLanguage('Bold');
  obj.setAttribute("rel", "b");
  obj.addEventListener('tap', function() {
                       var _this = this;
                       addActiveClass(objs, _this, "b");
                       });
  break;
  case "italic":
  obj.className = "wd-toolbox wd-italic";
  obj.innerHTML = "Ⅰ";
  obj.id = objs.id + "_I";
  obj.title = getMsgByLanguage('Italic');
  obj.setAttribute("rel", "i");
  obj.addEventListener('tap', function() {
                       var _this = this;
                       addActiveClass(objs, _this, "i");
                       });
  break;
  case "underline":
  obj.className = "wd-toolbox wd-underline";
  obj.title = getMsgByLanguage('Underline');
  obj.innerHTML = "U";
  obj.id = objs.id + "_U";
  obj.setAttribute("rel", "u");
  obj.addEventListener('tap', function() {
                       var _this = this;
                       addActiveClass(objs, _this, "u");
                       });
  break;
  case "insertimage":
  obj.className = "wd-toolbox wd-insertimages";
  obj.title = "上传图片";
  obj.id = objs.id + "_insertimage";
  
  obj.addEventListener("tap", function(event) {
                       if(!this.classList.contains("wd-toolbox-default")) {
                       switch(currentType) {
                       case "0":
                       var _this = this;
                       _this.classList.add("wd-insertimage-active");
                       initCursorPos(objs);
                       var btnArray = [{
                                       title: "拍照"
                                       }, {
                                       title: "从相册选择"
                                       }];
                       plus.nativeUI.actionSheet({
                                                 title: "选择照片",
                                                 cancel: "取消",
                                                 buttons: btnArray
                                                 }, function(e) {
                                                 var index = e.index;
                                                 switch(index) {
                                                 case 0:
                                                 _this.classList.remove("wd-insertimage-active");
                                                 break;
                                                 case 1:
                                                 var cmr = plus.camera.getCamera();
                                                 cmr.captureImage(function(path) {
                                                                  _this.classList.remove("wd-insertimage-active");
                                                                  path = "file://" + plus.io.convertLocalFileSystemURL(path);
                                                                  addImageEle(objs, path);
                                                                  if(!document.getElementById("wd_editImgWrap")) {
                                                                  addImgOptBox(objs);
                                                                  }
                                                                  }, function(err) {});
                                                 break;
                                                 case 2:
                                                 plus.gallery.pick(function(path) {
                                                                   _this.classList.remove("wd-insertimage-active");
                                                                   addImageEle(objs, path);
                                                                   if(!document.getElementById("wd_editImgWrap")) {
                                                                   addImgOptBox(objs);
                                                                   }
                                                                   }, function(err) {}, null);
                                                 break;
                                                 }
                                                 });
                       case "1":
                       initCont(objs);
                       initCursorPos(objs, "noFocus");
                       openChoiceAttachment();
                       break;
                       case "2":
                       initCursorPos(objs, "noFocus");
                       window.location.href="wd:"
                       break;
                       default:
                       break;
                       }
                       }
                       }, false);
		}
		return obj;
  }
  
  /**
   * 打开选择附件的窗口
   */
  function openChoiceAttachment() {
		Android.openChoiceAttachment();
  }
  })(mui);
var currentType = "0"; // 0:h5 1:android 2:ios
function setCurrentType(_currentType) {
    currentType = _currentType;
}

var language = 'ch';
function getMsgByLanguage(v){
    return languageObject[v][language];
}
// 设置语言环境，native调用
function setLanguage(curLanguage){
    language = curLanguage;
    console.log("切换到当前语言环境："+language);
}

var languageObject = {
    'Picture-set':{
        'ch':'图片设置',
        'en':'Image settings'
    },
    'Size':{
        'ch':'大小：',
        'en':'Size：'
    },
    'Width':{
        'ch':'宽度',
        'en':'width'
    },
    'Height':{
        'ch':'高度',
        'en':'height'
    },
    'Frame':{
        'ch':'边框：',
        'en':'Frame：'
    },
    'Margin':{
        'ch':'边距：',
        'en':'Margin：'
    },
    'Describe':{
        'ch':'描述：',
        'en':'Describe：'
    },
    'Ok':{
        'ch':'确定',
        'en':'OK'
    },
    'Cancel':{
        'ch':'取消',
        'en':'Cancel'
    },
    'Bold':{
        'ch':'加粗',
        'en':'Bold'
    },
    'Italic':{
        'ch':'斜体',
        'en':'Italic'
    },
    'Underline':{
        'ch':'下划线',
        'en':'Underline'
    }
}
