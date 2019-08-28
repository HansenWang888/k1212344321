// 获取请求地址
var requestType = "app";
// 应用版本
var version = "1.0.0";
// 是否混合
var isNative = false;

mui.plusReady(function() {
	// 存储父页面webViewId
	if(mui("#parentWebViewId").length == 0) {
		var inputBox = document.createElement('input');
		inputBox.id = "parentWebViewId";
		inputBox.style.display = "none";
		inputBox.type = "text"
		inputBox.value = (getQueryString("webViewId")) ? getQueryString("webViewId") : "";
		document.body.appendChild(inputBox);
	} else {
		mui("#parentWebViewId")[0].value = (getQueryString("webViewId")) ? getQueryString("webViewId") : "";
	}
});
// 处理横屏竖屏事件
var evt = "onorientationchange" in window ? "orientationchange" : "resize";
window.addEventListener(evt, function() {
	// 竖屏
	if(window.orientation === 180 || window.orientation === 0) {
		if(typeof orientation180 == "function") {
			orientation180();
		}
	}
	// 横屏
	if(window.orientation === 90 || window.orientation === -90) {
		if(typeof orientation90 == "function") {
			orientation90();
		}
	}
}, false);
// 是否竖屏显示
// flg：true竖屏显示
function lockOrientation(flg) {
	if(flg) {
		plus.screen.lockOrientation("portrait-primary");
	}
}

// mui全局处理
var first = null;
mui.init({
	beforeback: function() {
		//首次按键，提示‘再按一次退出应用’
		if(mui("#parentWebViewId")[0].value == "") {
			if(!first) {
				first = new Date().getTime();
				mui.toast('再按一次退出应用');
				setTimeout(function() {
					first = null;
				}, 1000);
			} else {
				if(new Date().getTime() - first < 1000) {
					plus.runtime.quit();
				}
			}
		}
		// 页面回调方法
		if(typeof beforeback === 'function') {
			beforeback.call();
		}
	}
});

// 设置json默认值
// defaults：默认值
// settings：返回值
function extendSettings(defaults, settings) {
	if(typeof(settings) != "object") {
		return defaults;
	} else {
		for(var o in defaults) {
			var addflg = true;
			var addobj;
			for(var n in settings) {
				if(o == n) {
					addflg = false;
					addobj = "";
					break;
				} else {
					addobj = o;
				}
			}

			if(addflg) {
				settings[addobj] = defaults[addobj];
			}
		}

		return settings;
	}
}
// 事件绑定
// settings.eventId：对象id
// settings.eventType：事件绑定类型，默认tap
// settings.eventFunction：触发方法体
function elementBindEvent(settings) {
	var defaults = {
		eventType: "tap"
	};
	settings = extendSettings(defaults, settings);
	mui("#" + settings.eventId)[0].addEventListener(settings.eventType, function() {
		if(settings.eventFunction) {
			settings.eventFunction.call('', this);
		}
	})
};
// 群组上事件
// settings.eventObj：父容器id
// settings.eventType：事件绑定类型
// settings.targetObj：带绑定控件组样式
// settings.eventFunction：触发方法体
function elementBindEventByObj(settings) {
	var defaults = {
		eventType: "tap"
	};
	settings = extendSettings(defaults, settings);
	mui("#" + settings.eventObj).on(settings.eventType, "." + settings.targetObj, function() {
		if(settings.eventFunction) {
			settings.eventFunction.call('', this);
		}
	})
};
// 页面跳转
// settings.pageUrl：页面url
// settings.postData：目标页面参数
// settings.aniShow：页面加载动态效果,默认为slide-in-right
function pageChange(settings) {
	if(!settings.postData) {
		settings.postData = {};
	}
	settings.postData.webViewId = plus.webview.currentWebview().id;
	var defaults = {
		aniShow: "slide-in-right"
	};
	settings = extendSettings(defaults, settings);
	mui.openWindow({
		id: settings.pageUrl,
		url: settings.pageUrl,
		show: {
			autoShow: true, //页面loaded事件发生后自动显示，默认为true      
			aniShow: settings.aniShow, //页面显示动画，默认为”slide-in-right“；      
			duration: 200 //页面动画持续时间，Android平台默认100毫秒，iOS平台默认200毫秒；    
		},
		waiting: {
			autoShow: false
		},
		extras: settings.postData
	});
};
// 获取请求参数
// name：参数名称
function getQueryString(name) {
	var self = plus.webview.currentWebview();
	return self[name];
};
//生成32位随机码
function newGuid() {
	var guid = "";
	for(var i = 1; i <= 32; i++) {
		var n = Math.floor(Math.random() * 16.0).toString(16);
		guid += n;
	}
	return guid;
};
// 获取请求地址
function getRequestAddressUrl(addKey) {
	var retUrl = "";
	for(var i = 0; i < requestAddressList.length; i++) {
		if(requestAddressList[i].addressKey == addKey) {
			retUrl = requestAddressList[i].url;

			break;
		}
	}

	return retUrl;
};

// 组合json
function jsonjoin(sorJosn, tarJosn) {
	sorJosn.push = function(o) {
		if(typeof(o) == 'object')
			for(var p in o) this[p] = o[p];
	};
	sorJosn.push(
		tarJosn
	)

	return sorJosn;
};
// 获取页面元素坐标位置-X坐标
function pageX(elem) {
	return elem.offsetParent ? (elem.offsetLeft + pageX(elem.offsetParent)) : elem.offsetLeft;
}
// 获取页面元素坐标位置-Y坐标
function pageY(elem) {
	return elem.offsetParent ? (elem.offsetTop + pageY(elem.offsetParent)) : elem.offsetTop;
}
// 调用父webview方法
// funName：方法名
// params：参数
function callParentWebViewFun(funName, params) {
	if(!params) {
		params = {};
	}
	var pageid = mui("#parentWebViewId")[0].value;
	mui.fire(plus.webview.getWebviewById(pageid), funName, params);
};

// 请求方法
// settings.url：请求路径
// settings.appurl：json请求路径
// settings.pastDate：参数json格式
// settings.addressKey：请求地址key，默认request
// settings.nativeFlg:是否为原生，默认false
// callBackFun：回调方法
function crossDomainAjax(settings, callBackFun) {
	var appurl = window.location.pathname.split('www')[0] + "www/";
	var defaults = {
		addressKey: "request",
		nativeFlg: false
	};
	if(!settings.appurl) {
		settings.appurl = settings.url;
	}
	settings = extendSettings(defaults, settings);
	var temp = new Date().getTime();
	var requestUrl;
	if(requestType == "request") {
		var temp = new Date().getTime();
		requestUrl = getRequestAddressUrl(requestType) + settings.url;
	} else {
		requestUrl = appurl + settings.appurl;
	}
	// 处理请求缓存
	if(requestUrl.indexOf('?') != -1) {
		requestUrl = requestUrl + "&time=" + temp + "&v=" + version;
	} else {
		requestUrl = requestUrl + "?time=" + temp + "&v=" + version;
	}

	// 处理参数
	for(var o in settings.pastDate) {
		requestUrl = requestUrl + "&" + o + "=" + settings.pastDate[o];
	}

	if((!settings.nativeFlg && !isNative) || (settings.nativeFlg && requestType == "request")) {
		var appAjax = new XMLHttpRequest();
		appAjax.open('GET', requestUrl, true);
		appAjax.send(null);
		appAjax.onreadystatechange = function() {
			if(appAjax.readyState == 4) {
				var responseDate = JSON.parse(appAjax.responseText);
				if(callBackFun) {
					callBackFun.call('', responseDate);
				}
				appAjax = null;
			}
		}
	} else {
		var jsonDataUrl = requestUrl;
		plus.io.requestFileSystem(plus.io.PRIVATE_WWW, function(fs) {
			fs.root.getFile(jsonDataUrl, {
				create: true
			}, function(fileEntry) {
				fileEntry.file(function(file) {
					var fileReader = new plus.io.FileReader();
					fileReader.readAsText(file, 'utf-8');
					fileReader.onloadend = function(evt) {
						var responseDate = eval("(" + evt.target.result + ")");
						if(callBackFun) {
							callBackFun.call('', responseDate);
						}
					}
				});
			});
		});
	}
}
// 获取相邻元素(内部方法)
function getNearEle(ele, type) {
	type = type == 1 ? "previousSibling" : "nextSibling";
	if(ele) {
		var nearEle = ele[type];
		while(nearEle) {
			if(nearEle.nodeType === 1) {
				return nearEle;
			}
			nearEle = nearEle[type];
			if(!nearEle) {
				break;
			}
		}
	}
	return null;
}
// 获取当前对象的上一个元素
// ele：当前对象
function prev(ele) {
	return getNearEle(ele, 1);
}
// 获取当前对象的下一个元素
// ele：当前对象
function next(ele) {
	return getNearEle(ele, 0);
}
// 获得匹配元素集合中每个元素前面的所有同胞元素
// ele：当前对象
// tarEle：查询的对象类型
function prevAll(ele, tarEle) {
	var prevEles = [];
	var ele = getNearEle(ele, 1);
	return pushEle(prevEles, ele, tarEle);

	function pushEle(prevEles, ele, tarEle) {
		if(ele) {
			if(tarEle) {
				if(ele.nodeName.toLowerCase() == tarEle || ele.className.indexOf(tarEle) != -1 || ele.id == tarEle) {
					prevEles.push(ele);
					ele = getNearEle(ele, 1);
					pushEle(prevEles, ele, tarEle);
				} else {
					ele = getNearEle(ele, 1);
					pushEle(prevEles, ele, tarEle);
				}
			} else {
				prevEles.push(ele);
				ele = getNearEle(ele, 1);
				pushEle(prevEles, ele, tarEle);
			}
		}
		return prevEles;
	}
}
// 获得匹配元素集合中每个元素的所有跟随的同胞元素
// ele：当前对象
// tarEle：查询的对象类型
function nextAll(ele, tarEle) {
	var nextEles = [];
	var ele = getNearEle(ele, 0);
	return pushEle(nextEles, ele, tarEle);

	function pushEle(nextEles, ele, tarEle) {
		if(ele) {
			if(tarEle) {
				if(ele.nodeName.toLowerCase() == tarEle || ele.className.indexOf(tarEle) != -1 || ele.id == tarEle) {
					nextEles.push(ele);
					ele = getNearEle(ele, 0);
					pushEle(nextEles, ele, tarEle);
				} else {
					ele = getNearEle(ele, 0);
					pushEle(nextEles, ele, tarEle);
				}
			} else {
				nextEles.push(ele);
				ele = getNearEle(ele, 0);
				pushEle(nextEles, ele, tarEle);
			}
		}
		return nextEles;
	}
}
// 当前对象前插入元素、newEle放到tarEle前面
function insertBefore(newEle, tarEle) {
	var parent = tarEle.parentNode;
	if(!parent) {
		parent = tarEle;
	}
	parent.insertBefore(newEle, tarEle);
}
// 当前对象后插入元素、newEle放到tarEle后面
function insertAfter(newEle, tarEle) {
	var parent = tarEle.parentNode;
	if(!parent) {
		parent = tarEle;
	}
	if(parent.lastChild == tarEle) {
		parent.appendChild(newEle);
	} else {
		parent.insertBefore(newEle, tarEle.nextSibling);
	}
}
// 获取指定元素 ele.find(tarEle)
function find(ele, tarEle) {
	var tarEles = [];
	var nodes = ele.childNodes;
	return getEle(tarEles, nodes, tarEle);

	function getEle(tarEles, nodes, tarEle) {
		for(var i = 0; i < nodes.length; i++) {
			var _contain = false;
			var nodesArr = [];
			if(nodes[i].className) {
				nodesArr = nodes[i].className.split(" ");
			}
			for(var j = 0; j < nodesArr.length; j++) {
				if(nodesArr[j] == tarEle) {
					_contain = true;
				}
			}
			if(nodes[i].nodeName.toLowerCase() == tarEle || nodes[i].id == tarEle || _contain) {
				tarEles.push(nodes[i]);
				getEle(tarEles, nodes[i].childNodes, tarEle);
			} else {
				getEle(tarEles, nodes[i].childNodes, tarEle);
			}
		}
		return tarEles;
	}
}
// 获取元素位置
// tarEle：当前元素
function index(tarEle) {
	var parent = tarEle.parentNode;
	var eleArr = parent.childNodes;
	var index = 0;
	for(var i = 0; i < eleArr.length; i++) {
		if(eleArr[i] == tarEle) {
			index = i;
			break;
		}
	}
	return index;
}
// 移除元素
// ele:当前元素
function remove(ele) {
	var parent = ele.parentNode;
	parent.removeChild(ele);
}
// 循环数组
function foreach(array, func) {
	for(var i = 0; i < array.length; ++i) {
		func(array[i]);
	}
};
// 滚动到对象底部
function scrollBottom(obj) {
	obj.scrollTop = obj.scrollHeight;
}
// 加载模板H5用
//languageUrl:国际化配置文件名称，命名规范"language_模块名_页面模板名称（可选）",注：不用传语言类型、文件后缀
//templateUrl:模板配置文件名称，命名规范"template_模块名_页面模板名称（可选）",注：不用传文件后缀
//templateId:需要模板展现的父容器id
//loadFunction:模板加载完成后回调方法
//parameters：回调方法参数
function getTemplate(settings) {
	if(isNative) {
		getTemplateNative(settings);
	} else {
		localStorage[settings.languageUrl] = "";
		var appurl = window.location.pathname.split('www')[0] + "www/";
		var languageType = plus.os.language.split('-')[0].toLowerCase();
		var languageData;
		var appAjaxLanguage = new XMLHttpRequest();
		appAjaxLanguage.open('GET', appurl + settings.languageUrl + "_" + languageType + ".properties", true);
		appAjaxLanguage.send(null);
		appAjaxLanguage.onreadystatechange = function() {
			if(appAjaxLanguage.readyState == 4) {
				languageData = eval("(" + appAjaxLanguage.responseText + ")");
				localStorage[settings.languageUrl] = appAjaxLanguage.responseText;
				var appAjax = new XMLHttpRequest();
				appAjax.open('GET', appurl + settings.templateUrl + ".html", true);
				appAjax.send(null);
				appAjax.onreadystatechange = function() {
					if(appAjax.readyState == 4) {
						var responseData = appAjax.responseText;

						responseData = changenDataByLanguage(responseDate, languageData);

						document.getElementById(settings.templateId).innerHTML = responseData;

						if(settings.loadFunction) {
							settings.loadFunction.call(null, settings.parameters, languageData);
						}
						appAjax = null;
					}
				}

				appAjaxLanguage = null;
			}
		}
	}
};
// 获取国际化信息原生用
//languageUrl:国际化配置文件名称，命名规范"language_模块名_页面模板名称（可选）",注：不用传语言类型、文件后缀
//languageData：返回国际化信息（json格式）
function getLanguageDataNative(settings) {
	localStorage[settings.languageUrl] = "";
	var appurl = window.location.pathname.split('www')[0] + "www/";
	var languageType = plus.os.language.split('-')[0].toLowerCase();
	var languageUrl = appurl + settings.languageUrl + "_" + languageType + ".properties";

	plus.io.requestFileSystem(plus.io.PRIVATE_WWW, function(fs) {
		fs.root.getFile(languageUrl, {
			create: true
		}, function(fileEntry) {
			fileEntry.file(function(file) {
				var fileReader = new plus.io.FileReader();
				fileReader.readAsText(file, 'utf-8');
				fileReader.onloadend = function(evt) {
					localStorage[settings.languageUrl] = evt.target.result;
				};
			});
		});
	});
	setTimeout(function() {
		settings.languageDataFn.call('', getLanguageDataAgain(settings.languageUrl));
	}, 100)

};
// 单独获取国际化信息
//key:国际化配置文件名称，命名规范"language_模块名_页面模板名称（可选）",注：不用传语言类型、文件后缀
//languageData：返回国际化信息（json格式）
function getLanguageDataAgain(key) {
	if(localStorage[key] != "") {
		return eval("(" + localStorage[key] + ")");
	} else {
		return getLanguageDataAgain(key);
	}
}

// 加载模板原生用
//languageUrl:国际化配置文件名称，命名规范"language_模块名_页面模板名称（可选）",注：不用传语言类型、文件后缀
//templateUrl:模板配置文件名称，命名规范"template_模块名_页面模板名称（可选）",注：不用传文件后缀
//templateId:需要模板展现的父容器id
//loadFunction:模板加载完成后回调方法
//parameters：回调方法参数
function getTemplateNative(settings) {
	localStorage[settings.languageUrl] = "";
	var appurl = window.location.pathname.split('www')[0] + "www/";
	var languageType = plus.os.language.split('-')[0].toLowerCase();
	var languageUrl = appurl + settings.languageUrl + "_" + languageType + ".properties";
	var templateUrl = appurl + settings.templateUrl + ".html";

	plus.io.requestFileSystem(plus.io.PRIVATE_WWW, function(fs) {
		fs.root.getFile(languageUrl, {
			create: true
		}, function(fileEntry) {
			fileEntry.file(function(file) {
				var fileReader = new plus.io.FileReader();
				fileReader.readAsText(file, 'utf-8');
				fileReader.onloadend = function(evt) {
					var languageData = eval('(' + evt.target.result + ')');
					localStorage[settings.languageUrl] = evt.target.result;
					fs.root.getFile(templateUrl, {
						create: true
					}, function(fileEntry) {
						fileEntry.file(function(file) {
							var fileReader = new plus.io.FileReader();
							fileReader.readAsText(file, 'utf-8');
							fileReader.onloadend = function(evt) {
								var responseData = changenDataByLanguage(evt.target.result, languageData);
								document.getElementById(settings.templateId).innerHTML = responseData;

								if(settings.loadFunction) {
									settings.loadFunction.call(null, settings.parameters, languageData);
								}
							}
						})
					})
				}
			});
		});
	});
}

// 替换语言信息
function changenDataByLanguage(responseData, languageData) {
	for(var o in languageData) {
		responseData = responseData.replace(new RegExp("\\{{" + o + "\\}}", "g"), languageData[o]);
	}
	return responseData;
}