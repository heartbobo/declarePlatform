<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core"  prefix="c"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>分配评审专家</title>
	<%@include file="../head.jspf"%>
	<style type="text/css">
		a{
			text-decoration:none;
		}
		
		#searchBox{
		    background: #fff8f8;
		    font-size: 12px;
		    width: 180px;
		}
		
		.datagrid-header-row td{
			background-color:#E0ECFF;
			font-weight:bold;
			height : 25px;
		}
		
		.datagrid-btable tr{
			height: 28px;
		}
	</style>
	
</head>
	<script type="text/javascript">
		$(function() {
			//datagrid初始化
			$('#dg').datagrid(
			{
				//请求数据的url
				url : '../../review1/listReview1.do?review1_status=2&history_flag=1',
				title : '当前列表',
				rownumbers : true,
				height : 800,
				//载入提示信息
				loadMsg : 'loading...',
				//水平自动展开，如果设置此属性，则不会有水平滚动条，演示冻结列时，该参数不要设置
				fitColumns : true,
				//数据多的时候不换行
				nowrap : true,
				//设置分页
				pagination : true,
				//设置每页显示的记录数，默认是10个
				pageSize : 15,
				//每页显示记录数项目
				pageList : [ 3, 5, 10, 15, 20 ],
				//指定id为标识字段，在删除，更新的时候有用，如果配置此字段，在翻页时，换页不会影响选中的项
				idField : 'review1_id',
				striped : true,	//隔行换色
				//上方工具条 添加 修改 删除 刷新按钮
				toolbar : '#toolbar',
				//同列属性，但是这些列将会冻结在左侧,z大小不会改变，当宽度大于250时，会显示滚动条，但是冻结的列不在滚动条内
				frozenColumns : [ [ 
					{field : 'ck', checkbox : true}, //复选框
				] ],
				onLoadSuccess: function (data) {
		            if (data.total != 0) {
		            	var array = [];
		            	for(var i = 0 ; i < data.rows.length; i++) {
		            		if(data.rows[i].apply_time != null)
		            			array.push(data.rows[i].apply_time);
		            	}
	            		if(array.length == 0) {
	            			$("#dg").datagrid("hideColumn", "apply_time");
	            			$("#dg").datagrid("hideColumn", "item_status");
	            		}
		            } else {
		            	$.messager.alert("提示框","未查询到相关数据！", "info");
		            }
		        },
				columns : [ [
					{field : 'item_id',title : '项目编号',align : 'center',width : 100, hidden : true}, 
					{field : 'item_name',title : '项目名称',align : 'center',width : 100}, 
					{field : 'item_type',title : '项目类别',align : 'center',width : 100},
					{field : 'item_user',title : '项目申报人',align : 'center',width : 100},
					{field : 'user_title',title : '职称',align : 'center',width : 100},
					{field : 'user_department',title : '所属系部',align : 'center',width : 100},
					{field : 'apply_year',title : '申报年份',align : 'center',width : 100},
					{field : 'apply_time',title : '系部审核时间',align : 'center',width : 100, formatter : datetimeFormatter}, 
					{field : 'review1_remark',title : '备注',align : 'center',width : 100}, 
					{field : 'item_status',title : '分配专家状态',align : 'center',width : 100, formatter : item_statusFormatter}, 
					{field : 'option',title : '操作',align : 'center',width : 100,formatter : optionFormatter}, 
				] ],
			});
		});
		
		function editApply() {
			//获取选中要修改的行
			var selectedRows = $("#dg").datagrid("getSelections");
			//确保被选中行只能为一行
			if (selectedRows.length != 1) {
				if(selectedRows.length  == 0) {
					$.messager.alert("系统提示","请选择一条记录进行修改！","info");
				} else {
					$.messager.alert("系统提示","一次只能选择一条记录！","warning");
				}
				return;
			}
			//获取选中行
			var row = selectedRows[0];
			row.item_starttime = dateFormatter(row.item_starttime);
			row.item_deadline = dateFormatter(row.item_deadline);
			//打开对话框并且设置标题
			$("#dlg").dialog("open").dialog("setTitle", "编辑项目申报书");
			//将数组回显对话框中
			$("#fm").form("load", row);//会自动识别name属性，将row中对应的数据，填充到form表单对应的name属性中
			//document.getElementById("user_name").disabled = true;
			url = "${pageContext.request.contextPath }/apply/updateApply.do";
		}
		
		function reload() {
			$("#dg").datagrid("reload");
		}
		
		function search() {
			var str = $("#searchBox").val();
			var user_department = $("#department").combobox("getValue");
			var item_type = $("#type").combobox("getValue");
    		
			$("#dg").datagrid("load",{
				str : str,
				user_department : user_department,
				item_type : item_type,
			});
		}
		
		function modify(index){
		 	//点击修改前需要将之前选中的行取消掉，然后才能得到当前选中行
			$("#dg").datagrid("unselectAll");
			$("#dg").datagrid("selectRow",index);
			var row = $("#dg").datagrid("getSelected");
			console.log(row);
			if(row) {
				$("#dlg2").dialog("open").dialog("setTitle", "分配评审专家");
				$("#fm2").form("load", row);
				url = "${pageContext.request.contextPath }/review2/addReview2.do";
			}
		};

		//定义全局url，用于修改和添加操作
		var url;
		// 添加或者修改用户
		function saveDialog() {
			$("#fm2").form("submit", {
				url : url,
				onSubmit : function() {
					return $(this).form("validate");
				}, //进行验证，通过才让提交
				success : function(data) {
					var data = JSON.parse(data);
					if (data.state) {
						$.messager.alert("系统提示", "恭喜您，分配专家成功！","info");
						$("#fm2").form("reset");
						$("#dlg2").dialog("close"); //关闭对话框
						$("#dg").datagrid("unselectAll");	//关闭对话框时取消所选择的行记录
						$("#dg").datagrid("reload"); //刷新一下
					} else {
						$.messager.alert("系统提示", "分配专家失败，请重新操作！","error");
						return;
					}
				}
			});
		}
	
		function closeDialog() {
			$("#fm2").form("reset");
			$("#dlg2").dialog("close"); //关闭对话框
			$("#dg").datagrid("unselectAll");	//关闭对话框时取消所选择的行记录
		}
		
		function dateFormatter(value){
			if(value != null) {
	            var date = new Date(value);
	            var year = date.getFullYear();
	            var month = date.getMonth() + 1;
	            if(month < 10) {
	            	month =  "0" + month;
	            }
	            var day = date.getDate();
	            if(day < 10) {
	            	day =  "0" + day;
	            }
	            return year + '-' + month + '-' + day;
			}
        }
        
        function datetimeFormatter(value){
        	if(value != null) {
	            var date = new Date(value);
	            var year = date.getFullYear();
	            var month = date.getMonth() + 1;
	            if(month < 10) {
	            	month =  "0" + month;
	            }
	            var day = date.getDate();
	            if(day < 10) {
	            	day =  "0" + day;
	            }
	            var hour = date.getHours();
	            if(hour < 10) {
	            	hour = "0" + hour;
	            }
	            var minute = date.getMinutes();
	            if(minute < 10) {
	            	minute = "0" + minute;
	            }
	            var second = date.getSeconds();
	            if(second < 10) {
	            	second = "0" + second;
	            }
	            return year + '-' + month + '-' + day + " " + hour + ":" + minute + ":" + second;
        	}
        }
        
		function item_statusFormatter(value,row,index) {
			if(value === "2") {
				return "<font color='red'>未分配</font>";
			} else if(value === "3" || value === "4" || value === "5" || value === "6") {
				return "<font color='green'>已分配</font>";
			}
		}
		
		function optionFormatter(value, row, index) {
			if(row.item_status === "2") {
				return [
		            "<a href='javascript:void(0);' onclick='modify(" + index + ")'><img src='${pageContext.request.contextPath }/jquery-easyui-1.3.4/themes/icons/pencil.png'/>分配评审专家</a>&nbsp;&nbsp;&nbsp;",  
		        ].join("");
			} else {
				return [
		            "<a href='javascript:void(0);' onclick='modify(" + index + ")'><img src='${pageContext.request.contextPath }/jquery-easyui-1.3.4/themes/icons/pencil.png'/>查看详细</a>&nbsp;&nbsp;&nbsp;",  
		        ].join("");
			}
		}
		
		function loadType() {
			$.ajax({
			    type: "POST",
			    url: '../../itemType/list.do',
			    dataType: "json",
			    success: function(data) {
			    	//js中的方法：unshift() 方法可向数组的开头添加一个或更多元素，并返回新的长度
			    	data.unshift({itemType_id : "", itemType_name : "-----请选择项目类别-----", "itemType_createTime" : "", "item_description" : "", "item_count" : ""});
			        $('#type').combobox({
			            data: data,
			            valueField: 'itemType_name',		//相当于数据库里的字段值
			            textField: 'itemType_name',			//显示在页面下拉列表上的字段值
			            onSelect : function(record) {
							//alert("选择一个时触发");
							//console.log(record);
						},
			        });
			        //默认选中第一项
			        $('#type').combobox('select',"-----请选择项目类别-----");
			    },
			});
		}
		
	</script>
	
	<body onload="loadType();">
		<div id="toolbar" style="padding:5px;">
			<!-- 工具栏 -->
			<div>
				<a class="easyui-linkbutton" data-options="iconCls:'icon-reload',plain:true" href="javascript:reload();">刷新</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<span>按条件查询：</span>&nbsp;&nbsp;
				<select id="department" name="user_department" class="easyui-combobox" style="width:150px;">
					<option value="">-----请选择所属系部-----</option>
					<option value="计算机系">计算机系</option>
					<option value="软件工程系">软件工程系</option>
					<option value="信息安全系">信息安全系</option>
					<option value="网络工程系">网络工程系</option>
				</select>
				<select id="type" name="item_type" class="easyui-combobox" style="width:150px;" >
					<!-- <option value="">-----请选择项目类别-----</option> -->
				</select>
				<input type="text" id="searchBox" name="str" placeholder="按项目名称或申报人查找" size="20" onkeydown="if(event.keyCode==13) search()"/>
				<a class="easyui-linkbutton" data-options="iconCls:'icon-search',plain:true," href="javascript:search();">查询</a>
			</div>
		</div>
		
		<table id="dg"></table>
		
		<div id="dlg" class="easyui-dialog" style="width:500px; height:480px; padding:10px 20px" data-options="iconCls:'icon-save',closed:true,buttons:'#dlg-buttons'">
			<form id="fm" method="POST">
				<input type="hidden" id="item_id" name="item_id"/>
				<table cellspacing="8px">
					<tr>
						<td>项目名称</td>
						<td>
							<input type="text" id="item_name" name="item_name" class="easyui-validatebox" required="true">
						</td>
					</tr>
					<tr>
						<td>项目类别</td>
						<td>
							<select id="item_type" class="easyui-combobox" name="item_type" style="width:150px;" data-options="valueField:'itemType_name',textField:'itemType_name',url:'../../itemType/list.do'" > 
								<!-- <option value="">-----请选择项目类别-----</option> -->
							</select>
						</td>
					</tr>
					<tr>
						<td>项目申报人</td>
						<td>
							<input type="text" id="item_user" name="item_user" class="easyui-validatebox" required="true">&nbsp;
						</td>
					</tr>
					<tr>
						<td>所属系部</td>
						<td>
							<select id="user_department" name="user_department" class="easyui-combobox" style="width:100px;">
								<option value="">-----请选择-----</option>
								<option value="计算机系">计算机系</option>
								<option value="软件工程系">软件工程系</option>
								<option value="信息安全系">信息安全系</option>
								<option value="网络工程系">网络工程系</option>
							</select> &nbsp;
						</td>
					</tr>
					<tr>
						<td>起始日期</td>
						<td>
							<input type="text" id="item_starttime" name="item_starttime" class="easyui-datebox" required="true">&nbsp;
						</td>
					</tr>
					<tr>
						<td>截止日期</td>
						<td>
							<input type="text" id="item_deadline" name="item_deadline" class="easyui-datebox" required="true">&nbsp;
						</td>
					</tr>
					<tr>
						<td>项目描述</td>
						<td>
							<input type="text" id="item_description" name="item_description" class="easyui-validatebox" required="true">&nbsp;
						</td>
					</tr>
				</table>
			</form>
		</div>
		
		<div id="dlg2" class="easyui-dialog" style="width:500px; height:480px; padding:10px 20px" data-options="closed:true,buttons:'#dlg-buttons'">
			<form id="fm2" method="POST">
				<input type="hidden" id="item_id" name="item_id"/>
				<table cellspacing="8px">
					<tr>
						<td>项目名称</td>
						<td>
							<input type="text" id="item_name" name="item_name" class="easyui-validatebox" required="true">
						</td>
					</tr>
					<tr>
						<td>项目类别</td>
						<td>
							<select id="item_type" class="easyui-combobox" name="item_type" style="width:150px;" data-options="valueField:'itemType_name',textField:'itemType_name',url:'../../itemType/list.do'" > 
								<!-- <option value="">-----请选择项目类别-----</option> -->
							</select>
						</td>
					</tr>
					<tr>
						<td>项目申报人</td>
						<td>
							<input type="text" id="item_user" name="item_user" class="easyui-validatebox" required="true">&nbsp;
						</td>
					</tr>
					<tr>
						<td>所属系部</td>
						<td>
							<select id="user_department" name="user_department" class="easyui-combobox" style="width:100px;">
								<option value="">-----请选择-----</option>
								<option value="计算机系">计算机系</option>
								<option value="软件工程系">软件工程系</option>
								<option value="信息安全系">信息安全系</option>
								<option value="网络工程系">网络工程系</option>
							</select> &nbsp;
						</td>
					</tr>
					<tr>
						<td><h3>选择评审专家</h3></td>
						<td>
							<select id="review2_user" class="easyui-combobox" name="review2_user" style="width:150px;" data-options="valueField:'real_name',textField:'real_name',url:'../../user/listExpert.do'" > 
								<!-- <option value="">-----请选择项目类别-----</option> -->
							</select>
						</td>
					</tr>
				</table>
			</form>
		</div>
	
		<div id="dlg-buttons">
			<div align="center">
				<a href="javascript:saveDialog()" class="easyui-linkbutton"
					data-options="iconCls:'icon-ok',plain:true">保存</a>&nbsp;&nbsp;&nbsp;
				<a href="javascript:closeDialog()" class="easyui-linkbutton"
					data-options="iconCls:'icon-cancel',plain:true">关闭</a>
			</div>
		</div>
	</body>
</html>