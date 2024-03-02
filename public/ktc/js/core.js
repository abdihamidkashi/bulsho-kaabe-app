$(function(){
    var URLROOT = $("#domain").text();
    var co = $("#co").text();
    var user = $("#us").text();
    var co_id = $("#co").text();
    var user_id = $("#us").text();
    
    
  
    
    $(".ktc-dropdown").each(function(){
            
         	
            var action = $(this).attr("action");
            var id= "0";
            var data = "sp=20&action="+action+"&id="+id+"&user="+user+"&co="+co;
                //alert(url);
               // alert(data);
            
            var select = $(this);
         var default_value = $(this).attr("default");
    var url = URLROOT+"/forms/options/dropdown/"+default_value;
         var selected = "";
            $.post(url,data,function(res){
            /*    
            alert(res); //ll
                list = $.parseJSON(res);
     		//	alert(list);
                $.each(list, function(index, value) {
                 var j2a = []; 
              
            for(var i in value) {
            
                j2a.push(value[i]); 
            
                }
                if(default_value == j2a[0]) {
                	selected = "selected";
                }else{
                selected = "";
                }
                
            select.append("<option value='"+j2a[0]+"' "+ selected +" >"+j2a[1]+ "</option>");
                
                });
                */
            select.append(res);
            });
        });
       
       $(".ktc-radio").each(function(){
       
         	var type = "radio";
         	if($(this).hasClass("checkbox")){
         	    type = "checkbox";
         	}
       
         
         	
            var action = $(this).attr("action");
            var name = $(this).attr("id");
            
       		var default_value = $(this).attr("default");
            var url = URLROOT+"/forms/options/"+type+"/"+default_value+"/"+name;
       
            var id= "0";
            var data = "sp=20&action="+action+"&id="+id+"&user="+user+"&co="+co;
               // alert(url);
                //alert(data);
            
            var select = $(this);
         
         var selected = "";
            $.post(url,data,function(res){
                //alert(res); //ll
            /*
                list = $.parseJSON(res);
     		//	alert(list);
     		var item = 0;
                $.each(list, function(index, value) {
                    item++;
                 var j2a = []; 
              
            for(var i in value) {
            
                j2a.push(value[i]); 
            
                }
                if(default_value == j2a[0]) {
                	selected = "selected";
                }else{
                selected = "";
                }

            if(type == 'checkbox'){
                    select.append("<input name='"+name+"[]' type='checkbox' id='r"+item+"' value='"+j2a[0]+"'  /> <label for='r"+item+"'>"+j2a[1]+"</label> &nbsp;");

            }else{
                            select.append("<input name='"+name+"' type='radio' id='r"+item+"' value='"+j2a[0]+"'  /> <label for='r"+item+"'>"+j2a[1]+"</label>  &nbsp;");

            }
                
                });
                */
             select.append(res);
            });
        });
       

       $(".check-all-checkbox").change(function(){
           if($(this).is(":checked")){
            $(this).closest(".checkbox").find("input[type=checkbox]").attr("checked", true);

           }else{
               $(this).closest(".checkbox").find("input[type=checkbox]").attr("checked", false);
           }
       })
        
         $(".ktc-autocomplete").keyup(function(){
    
    		var prefix = $(this).val();
    	
     var ul = $(this).closest(".ktc-form-box").find("ul");
    if(prefix == "" || prefix.length < 3){
    	ul.html("");
    return false;
    }
    	ul.html("");
    
    	 var url = URLROOT+"/forms/options/autocomplete";
          
    
    var data = "sp=5&action="+$(this).attr("action")+"&prefix="+prefix+"&co="+co+"&user="+user
                
                //alert(url);
               // alert(data);
            
           
            $.post(url,data,function(res){
                //alert(res);
            /*    
            list = $.parseJSON(res);
					
            
                $.each(list, function(index, value) {
                      var j2a = []; 
              
            for(var i in value) {
            
                j2a.push(value[i]); 
            
                }
                    ul.append("<li class='list-group-item ktc-autocomplete-item'  value='"+j2a[0]+"'>"+j2a[1]+"</li>");
                });
            */
            
            ul.html(res);
            });
    	
    });
    
    $("body").delegate(".ktc-autocomplete-item", "click", function(){
    	var id = $(this).attr("value");
    var text = $(this).text();
    	$(this).closest(".ktc-form-box").find(".ktc-autocomplete").val(text);
    	$(this).closest(".ktc-form-box").find(".ktc-autocomplete-id").val(id);
    
    $(this).closest(".ktc-form-box").find(".ktc-autocomplete").trigger('blur');
      $(this).closest(".ktc-form-box").find(".ktc-autocomplete").trigger('change');
    
    
    	var ul = $(this).closest("ul");
    		
    if(ul.hasClass("auto-update")){
    	var td = ul.closest("td");
    	updatable(td, id);
    }
    
    	ul.empty();
    });
    
    
    $(".ktc-form2").submit(function(e){
    	e.preventDefault();
       

    	var url = $(this).attr("action");
    	var data = $(this).serialize();
    	
    	var form = $(this); 
    
    	//alert(url);
    	//alert(data);
        
    	$.post(url,data,function(res){
        //alert(res);
        var res = res.split("|");
        	form.next().html('<div class="alert alert-'+res[0]+'"><strong>'+res[0]+'</strong> '+res[1]+' </div>');
        })
    
    });
    
    $("body").delegate(".ktc-form-create","submit",function(e){
    	e.preventDefault();
    
        
    
    	var url = $(this).attr("action");
    var frm = $(this);
    if($(this).hasClass('edit-form')){
    var description = window.prompt("Type Update Reason or Description", "Qalad iga dhacay");
		if ( typeof description !== 'undefined' && description != "") {
        	frm.find(".ktc-why-update").val(description);
        }else{
        return false;
        }
    }
    
   
    	var data = new FormData(this);
    	//var data2 = $(this).serialize();
    	
    	// console.log(data2);
    	var terms = $('#terms').length;
    	if(terms == 1 && !$('#terms').is(":checked")){
    	    alert("Fadlan saxiix inaad aqbashay shuruudaha isticmaalka (Terms of Use)");
    	    return;
    	}
    
    
	
	var btn = $(this).find(".button");
	var text = $(this).find(".button").text();
	
	btn.attr("disabled",true);
	btn.text("Wiat...");
//alert(data2);
	$.ajax({
	   
	    
		url: url,
		data: data,
		    xhr: function() {
                var xhr = new window.XMLHttpRequest();
                xhr.upload.addEventListener("progress", function(evt) {
                    if (evt.lengthComputable) {
                        var percentComplete = evt.loaded / evt.total;
                        var pr =  (Math.round(percentComplete * 100));
frm.next().html('<div class="progress"><div '+'class="progress-bar progress-bar-striped active" role="progressbar" aria-valuenow="'+pr+'" aria-valuemin="0"'+
'aria-valuemax="100" style="width:'+pr+'%">'+
     ''+pr+'%</div>');
                    }
                }, false);
                return xhr;
            },
		method: "POST",
		contentType: false,
		processData: false,
		success: function(res){
		//	alert(res);
			
		if( $('#visitorModal').length )         // use this if you are using id to check
            {
                 // it exists
                 $("#visitorModal").modal("hide");

            }
        var res = res.split("|");
        	frm.next().html('<div class="alert alert-'+res[0]+'"><strong>'+res[0]+'</strong> '+res[1]+' </div>');
			
				btn.attr("disabled",false);
				
				btn.text(text);
				
			//	btn.removeClass("load");

			
		},
		error: function(jqXHR, exception) {
            
  ajax_error(jqXHR.status, exception, jqXHR.responseText);
                    
            	btn.attr("disabled",false);
				
				btn.text(text);
        }
	});
});
   
   function ajax_error(status, exception, response){
    if (status === 0) {
                alert('Not connect.\n Verify Network.');
            } else if (status == 404) {
                alert('Requested page not found. [404]');
            } else if (status == 500) {
                alert('Internal Server Error [500].');
            } else if (exception === 'parsererror') {
                alert('Requested JSON parse failed.');
            } else if (exception === 'timeout') {
                alert('Time out error.');
            } else if (exception === 'abort') {
                alert('Ajax request aborted.');
            } else {
                alert('Uncaught Error.\n' + response);
            }
}
   
      $("body").delegate(".ktc-form-report","submit",function(e){
    	e.preventDefault();
    
    	var url = $(this).attr("action");
      if(url.includes("forms/update")){
        	var data = "sp=48&t="+$("input[name='user_p']").val()+"&a="+$("input[name='category_p']").val()+"&id="+$("select[name='link_p']").val()+"&c="+$("input[name='co_p']").val();
	//alert(data);
    var url = URLROOT+"/forms/update";
	$.post(url,data,function(res){
	   // $("#update-modal").find(".modal-body").html(res);
	    //	$("#update-modal").modal("show");
    var res = "<div class='row'><div class='col-md-3'></div><div class='col-md-7'>"+res+"</div></div>";
    	$("#ktc-report-placeholder").html(res);
	});
        return false; 
        }
    	var data = new FormData(this);
    	var data2 = $(this).serialize();
    	
    	var frm = $(this);
	
	var btn = $(this).find(".button");
	var text = $(this).find(".button").text();
	
	btn.attr("disabled",true);
	btn.text("Wiat...");
    //alert(data2);
	$.ajax({
	   
	    
		url: url,
		data: data,
		    xhr: function() {
                var xhr = new window.XMLHttpRequest();
                xhr.upload.addEventListener("progress", function(evt) {
                    if (evt.lengthComputable) {
                        var percentComplete = evt.loaded / evt.total;
                        var pr =  (Math.round(percentComplete * 100));
frm.next().html('<div class="progress current-prog"><div '+'class="progress-bar progress-bar-striped active " role="progressbar" aria-valuenow="'+pr+'" aria-valuemin="0"'+
'aria-valuemax="100" style="width:'+pr+'%">'+
     ''+pr+'%</div>');
                    }
                }, false);
                return xhr;
            },
		method: "POST",
		contentType: false,
		processData: false,
		success: function(res){
			//alert(res);
			
		
        	//frm.next().html('<div class="alert alert-'+res[0]+'"><strong>'+res[0]+'</strong> '+res[1]+' </div>');
			
			$("#ktc-report-placeholder").html(res);
			
				btn.attr("disabled",false);
				
				btn.text(text);
				$(".current-prog").addClass("d-none");
				
			//	btn.removeClass("load");

			
		},
		error: function(jqXHR, exception) {
            
  ajax_error(jqXHR.status, exception, jqXHR.responseText);
                    
            	btn.attr("disabled",false);
				
				btn.text(text);
        }
	});
});
    
    
       $("body").delegate("tbody .updatable","dblclick",function(){

     	$(this).attr("contenteditable",true);
     });
    
    $("body").delegate("tbody .updatable","blur",function(){
   
    var td = $(this);
    
    var val = $.trim(td.text());
    
    updatable(td,val);
    
    });

function updatable(td, val){

 var table =td.closest("table");
    
    var tr = td.closest("tr");
	var td_index = td.index();
    

	 var description = window.prompt("Type Update Reason or Description", "Qalad iga dhacay");
		if ( typeof description !== 'undefined' && description != "") {
        
    	var table_col = $.trim(table.find("th").eq(td_index).attr("alt")).split(",");
    	var data = "sp=16&id="+$.trim(tr.find(".id").text())+"&t="+$.trim(table_col[1])+"&c="+$.trim(table_col[0])+"&v="+val+"&w=id&di_resu="+user+"&di_oc="+co+"&description="+description;
   // alert(data);
    	var url = URLROOT+"/forms/save";
    	
    	$.post(url,data,function(res){
        var r = res.split("|");
        	if(r[0] == "success"){
        	td.css("color","green");
            }else{
            td.css("color","red");
            td.attr("title", res);
            td.text(txt);
            }
        
        });
        	 
        }
}
    
    $("body").delegate(".ktc-gen-sp","click",function(){
	var tr = $(this).closest("tr");
	
	var table = $.trim(tr.find(".table").text());
	
    var unique_columns = $.trim(tr.find(".unique_columns").text());
    
	var icon = $(this);
	
    var data = "table="+table+"&unique_columns="+unique_columns;
	var url = URLROOT + "/forms/generateProc";
//	alert(url);
	$.post(url,data, function(res){
		//$("#msg-placeholder2").html(res);
		//alert(res);
		if(res.indexOf("1")> -1){
		    
	icon.removeClass("fa fa-remove");
	icon.addClass("fa fa-check");
		}
	})
});


var del_tr,del_td,del_data ;

$("body").delegate(".ktc-delete","click",function(e){
	e.preventDefault();
	
	if($(this).hasClass("no-delete")){
	    alert("Can't delete, becouse of $");
	    return false;
	}
	
		$("#ktc-del-id").val($(this).attr("id"));
		$("#ktc-del-t").val($(this).attr("alt"));
		$("#ktc-del-c").val($(this).attr("column"));
		
		del_tr = $(this).closest("tr");
        del_td = $(this);
        
	del_tr.remove();
	$("#delete-modal").modal("show");
	

	
});

$("body").delegate(".ktc-cancel","click",function(e){
	e.preventDefault();
	
	if($(this).hasClass("no-delete")){
	    alert("Can't delete, becouse of $");
	    return false;
	}
	
		$("#ktc-cancel-id").val($(this).attr("id"));
		$("#ktc-cancel-t").val($(this).attr("alt"));
		$("#ktc-cancel-c").val($(this).attr("column"));
		$("#ktc-cancel-status").val($(this).attr("status"));
		
		del_tr = $(this).closest("tr");
        del_td = $(this);
        
	del_tr.remove();
	$("#cancel-modal").modal("show");
	

	
});
$("body").delegate(".ktc-update","click",function(e){
	e.preventDefault();
	var data = "sp=48&t="+$(this).attr("t")+"&a="+$(this).attr("a")+"&id="+$(this).attr("id")+"&c="+$(this).attr("c");
	//alert(data);
    var url = URLROOT+"/forms/update";
	$.post(url,data,function(res){
	    $("#update-modal").find(".modal-body").html(res);
	    	$("#update-modal").modal("show");
	});
	


});

$("body").delegate(".ktc_check_category","change",function(){
        
        $(this).parent().find(".ktc-check-link").trigger("click");
    
    
});

$("body").delegate(".ktc-check-link","change",function(){
    var gr="revoke";
if($(this).is(":checked")){
    gr="grant";
    
}
    var data="sp=54&id="+$(this).val()+"&user1="+$(this).attr("u1")+"&di_resu="+$(this).attr("u2")+"&acttion="+$(this).attr("action")+"&grant="+gr+"&di_oc="+$(this).attr("co");
    var url= URLROOT+"/forms/save";
//alert(url+data);
    //$(this).next().find(".checkbox").prop("checked",true);
    $.post( url,data,function(res){
      //  alert(res);
        $("#msg-placeholder2").html(res);
    	});
	
});


$("body").delegate(".ktc-error-report","click",function(e){
    e.preventDefault();
 
    var data=  $(this).attr("data");
    var url= URLROOT+"/forms/save";
//alert(url+data);
     
    $.post( url,data,function(res){
        alert(res);
       
    	});
	
});




				$("body").delegate(".load, .load_check, .load2, .load_check2","change", function(){
               // alert(1);
$(this).trigger("blur");

});


$("body").delegate(".load, .load_check, .load2, .load_check2 ","blur",function(){
 
var action = $.trim($(this).attr("load_action"));

if(action == ""){
return true;
}
    

    var first_load = $(".ktc-form .load").first();
    
    var second_load = $(".ktc-form .load").eq(1);
    
     var third_load = $(".ktc-form .load").eq(2);
    
     var fourth_load = $(".ktc-form .load").eq(3);
    
     var fifth_load = $(".ktc-form .load").eq(4);
     
     var six_load = $(".ktc-form .load").eq(5);
     
    
    
    if($(this).is(first_load)){
           $(".load_me").trigger("dblclick");
    }
    if($(this).is(second_load)){
           $(".load2_me").trigger("dblclick");
    }
    else if($(this).is(third_load)){
           $(".load3_me").trigger("dblclick");
    }
    
     else if($(this).is(fourth_load)){
           $(".load4_me").trigger("dblclick");
    }
    
     else if($(this).is(fifth_load)){
          // alert(5);
           $(".load5_me").trigger("dblclick");
    }
    
     else if($(this).is(six_load)){
       
           $(".load6_me").trigger("dblclick");
           
    }
    
    
    var val= $(this).val();
	
   
    if($(this).hasClass("ktc-autocomplete")){
        val = $(this).closest(".ktc-form-box").find(".hidden-auto").val();
    }
    
     if(val == "%" || val == ""){
        return false;
    }




	// specific for load2 & load_check2 
	if($(this).hasClass("load2") || $(this).hasClass("load_check2")){
       var prev_load =  $(this).closest(".ktc-form-box").prev().find(".load");
    	
    if(prev_load.hasClass("ktc-autocomplete")){
    	val += "|" + prev_load.closest(".ktc-form-box").find(".hidden-auto").val();
    }else{
    	val += "|" + prev_load.val();
    }
  //  alert(val);
    }
    	var select = $(this).closest(".ktc-form-box").next().find("select");

    var type = "dropdown";
    if($(this).hasClass("load_check")){
        type = "checkbox";
        select =$(this).closest(".ktc-form-box").next().find(".checkbox-div");
    }
    
    var co_id2 = $("select[name='_comapny_id']").val();
    var co_id3 = $("select[name='co_p']").val();
    
    if(co_id2 > 0){
        co_id = co_id2;
    }
    if(co_id3 > 0){
        co_id = co_id3;
    }
    
    var data = "sp=20&action="+action+"&id="+val+"&user_id="+user_id+"&co_id="+co_id;
   // alert(data+type);

	load(data,select,type);
	    

	
});

$("body").delegate(".load_me","dblclick",function(){
    
    var id = $(".ktc-form .load").first();
    
   var val = id.val();
   
    if(id.hasClass("autocomplete")){
        val = id.closest(".ktc-form-box").find(".hidden-auto").val();
    }


     if(val == "%" || val == ""){
        return false;
    }
    
    var data = "sp=20&action="+$.trim($(this).attr("load_action"))+"&id="+val+"&user_id="+user_id+"&co_id="+co_id;
  
    var select = $(this);
    // alert(select.html());
    load(data,select,"dropdown");
});


$("body").delegate(".load2_me, .load3_me,.load4_me,.load5_me,.load6_me","dblclick",function(){
    
    var id = 0;
    if($(this).hasClass("load2_me")){
    id= $(".ktc-form .load").eq(1);
    }else if($(this).hasClass("load3_me")){
    id= $(".ktc-form .load").eq(2);
    }else if($(this).hasClass("load4_me")){
    id= $(".ktc-form .load").eq(3);
    }else if($(this).hasClass("load5_me")){
    id= $(".ktc-form .load").eq(4);
    }else if($(this).hasClass("load6_me")){
    id= $(".ktc-form .load").eq(5);
    }
    
   var val = id.val();
   
    if(id.hasClass("autocomplete")){
        val = id.closest(".ktc-form-box").find(".hidden-auto").val();
    }


     if(val == "%" || val == ""){
        return false;
    }
    
    var co_id2 = $("select[name='_comapny_id']").val();
    var co_id3 = $("select[name='co_p']").val();
    
    if(co_id2 > 0){
        co_id = co_id2;
    }
    if(co_id3 > 0){
        co_id = co_id3;
    }
    
    var data = "sp=20&action="+$.trim($(this).attr("load_action"))+"&id="+val+"&user_id="+user_id+"&co_id="+co_id;
  	//alert(data);
    var select = $(this);
    // alert(select.html());
    load(data,select,"dropdown");
});



function load(data,select,type){

    	select.addClass("loader-img"); 
    	var url = URLROOT+"/forms/options/"+type;
      // alert(data);
    	$.ajax({
	    url: url,
	    method: "POST",
	    data: data,
	    success: function(res){
	     //	alert(res);
	     	/*
		 //alert(type); //ll
                list = $.parseJSON(res);
     		//	alert(list);
     		var item = 0;
     		 select.html("");
            if(type == "dropdown"){
            select.append("<option value='%'>Choose All</option>");

            }
                $.each(list, function(index, value) {
                    item++;
                    
                 var j2a = []; 
              
            for(var i in value) {
            
                j2a.push(value[i]); 
            
                }
                
                
               if(type == "checkbox"){
                  
               select.append("<input name='"+name+"' type='checkbox' id='r"+item+"' value='"+j2a[0]+"'  /> <label for='r"+item+"'>"+j2a[1]+"</label>");

                   
               }else{
                 
             select.append("<option value='"+j2a[0]+"'>"+j2a[1]+ "</option>");

               }
                }); 
                */
        if(type == "dropdown"){
        var res = "<option value='%'>Choose All</option>"+res;
        }
        select.html(res);
        if(select.hasClass("copy")){
        	select.closest(".ktc-form-box").next().find(".paste").html(res);
        }
	   select.removeClass("loader-img"); 
                 
	    },
	    error: function(jqXHR, exception){
	    
	      ajax_error(jqXHR.status, exception, jqXHR.responseText);
	      select.removeClass("load-btn"); 
	      

	    }
	});
}


$("body").delegate(".ktc-tick","click",function(){
if($(this).hasClass("error")){
alert($(this).attr("title"));
return false;
}
	var tr = $(this).closest("tr");
	var data = "";
	var icon = $(this);
	icon.attr("disabled",true);
	var i = 0;
	var error = 0;
	 $(".auto").find(".req").removeClass("req");
	tr.find("td.req").each(function(){
		i++;
		var txt = $.trim($(this).text());
    	var tdclass = $.trim($(this).attr("class"));
    
		if(txt == "" && $(this).hasClass("required")){
		    $(this).css("background","red");
		    $(this).attr("title","This field is required to fill");
		    icon.attr("disabled",false);
		   // alert("This field is required to fill");
		   error = 1;
		
		    
		}else{
		     $(this).css("background","white");
		    $(this).attr("title","");

		}
		 if($(this).hasClass("select") || $(this).hasClass("ktc-dropdown")){
		    data+= "&p"+i+"="+$.trim($(this).find("select").val());
        // alert(data);
		}else if($(this).hasClass("auto")){
		    data+= "&p"+i+"="+$.trim($(this).find(".autocomplete-value").val());
		   
		}else{
		data+= "&p"+i+"="+encodeURIComponent(txt);
		}
    	console.log(data+'-'+tdclass);
	});
	if(error == 1){
	    return false;
	}
	//alert(data);
 if(icon.hasClass("fa-check")) {
var make_icon_type = "remove";
 var remove_icon_type = "check";
 
 
}else{
var make_icon_type = "check";
 var remove_icon_type = "remove";
 
}
	$.ajax({
	    url: URLROOT+"/forms/save2",
	    data: data,
	    method: "POST",
	    success: function(res){
	    //alert(res);
	   var r = res.split("|");
	   if(r.length > 2){
	       window.location.href = "whatsapp://send?text="+r[1]+"&phone="+r[2];
	   }
	   icon.attr("title",res);
        var r = res.split('|');
        $("#msg-placeholder2").addClass("alert alert-"+r[0]);
		$("#msg-placeholder2").html(r[1]);
		if(res.indexOf("success")> -1){
	icon.removeClass("fa fa-"+remove_icon_type);
	icon.addClass("fa fa-"+make_icon_type);
	tr.removeClass("bg-danger");
        icon.attr('disabled',false);
		}else{
		   // alert(res)
		    var notag = $(res).text();
		    tr.css("background:red !important");
		    tr.each(function(){
		        $(this).attr("title",notag);
		    })
		    
		}

	  },
		error: function(jqXHR, exception) {
		    ajax_error(jqXHR.status, exception, jqXHR.responseText);
        
            
            		icon.attr("disabled",false);


        }
	})
});


$("body").delegate("#save-all-selected","click",function(e){
    e.preventDefault();
    var t = $("#ktc-datatable").attr("table");
    var c = $("#ktc-datatable").attr("columns")
    var data = "";
    var r = 0;
    $("#ktc-datatable tbody tr").each(function(){
        var tr = $(this);
       
        //if($(this).find(".rp-checkbox").is(e":checked")){
             data = "t="+t+"&c="+c;
             var i = 0;
           $(this).find(".req").each(function(){
               data+="&p"+i+"="+encodeURIComponent($.trim($(this).text()));
               i++;
           }) 
           //alert(data);
           $.post(URLROOT+"/forms/insert",data,function(res){
               //alert(res);
             tr.removeClass("tr-hover");
               if($.trim(res) == 1){
                   tr.css("background-color","green");
               }else{
                   tr.css("background-color","red"); 
                   tr.find(".rp-checkbox").attr("title",res);
               }
           });
       // }
    })
});



$("body").delegate("#generate-modal","click",function(e){
	
	if( $("#ktc-datatable").hasClass("no-datatable")){
    
    	 $("#reprt-table-modal").html($("#ktc-datatable").html());
    }else{
   //Generates report modal
    var th = $("#ktc-datatable").find("thead").html();
    var tf = $("#ktc-datatable").find("tfoot").html();
    var tb = $("#ktc-datatable").dataTable().fnGetNodes();
    
    $("#reprt-table-modal thead").html(th);
    $("#reprt-table-modal tbody").html(tb);
    $("#reprt-table-modal tfoot").html(tf);
    
    }

    if($(this).hasClass("normal-table")){
    $("#reprt-table-modal").removeClass();
    }

	var dir = $("#ktc-datatable").attr("dir");
	$("#reprt-table-modal").attr("dir",dir);

$('#report-header').html($('#report-header2').html());
    //dropdowns convert to text
    $("#reprt-table-modal tbody tr").each(function(){
        $(this).find(".dropdown-to-text").each(function(){
            var txt = $(this).find("select option:selected").text();
            $(this).text(txt);
        })
    })

$('#report-footer').html($('#report-footer2').html());
   
     $("#reprt-table-modal .ignore").remove();
     $("#reprt-table-modal .hide").remove();
     
    
    
    
    
    //Generate Report headers
    var i = 0;
     var right_data = "";
    var left_data = "";
    $(".ktc-form-report .form-group").each(function(){
        var lbl = $.trim($(this).find("label").text());
        var ele = $(this).find(".form-control");

        if(ele.is("select")){
           lbl = $(ele).find("option:first-child").text();
        }
if(lbl == ""){
return true;
}
    i++;
   
    //var lbl = $.trim($(this).find("label").text());
    var val = $.trim($(this).find(".form-control").val());
    
    if($(this).find(".form-control").hasClass("select") && val != "%"){
    	val = $.trim($(this).find(".form-control").find("option:selected").text());
    }
    
    if(val == "%"){
        val = "All"
    }
    
    lbl = lbl.replace("Select", "");
    lbl = lbl.replace("Choose", "");
    lbl = lbl.replace("Dooro", "");
    
    
    if(i % 2 == 0){
    	left_data += "<tr><td style='text-align:right'><b>"+lbl+" : </b> </td> <td> "+val+"</td></tr>";
    }else{
    right_data += "<tr><td style='text-align:right'> <b> "+lbl+" : </b> </td> <td> "+val+"</td></tr>";
    }
    
    });
    
    $(".left-table").html(left_data);
    $(".right-table").html(right_data);
	    	$("#report-modal table").removeClass("table");

	    	$("#report-modal").modal("show");
	    	//$("#report-modal").delegate(".ignore")remove()
});


	$("body").delegate(".print-report","click",function(e){
			printDiv("printable-area");
		});
      		function printDiv(div) {
$(".modal-body").removeClass("table-responsive");
  var divToPrint=document.getElementById(div);

  var newWin=window.open('','Print-Window');

  newWin.document.open();

  newWin.document.write('<html ><head><link rel="stylesheet" href="'+URLROOT+'/plugins/bootstrap/css/bootstrap.min.css"   type="text/css" media="screen,print"  />'+
                        '<link rel="stylesheet" href="'+URLROOT+'/ktc/css//print.css" media="screen,print" type="text/css" /> </head>'+
                        '<body style="-webkit-print-color-adjust: exact;" onload="window.print()">'+divToPrint.innerHTML+'</body></html>');

  newWin.document.close();


}


$(".tell").blur(function(e){
                 $(".error-span").remove();

        	if($(this).val().length < 9){
              e.preventDefault();
            $(this).val("");
var error =  'Tel must be 9+ digits..' ;
        $(this).after("<span class='text-danger text-sm text-bold text-italic error-span'>"+error+"</span>");
            }
        });

$("body").delegate(".exportExcel","click",function(){
            	//toExcel("printablediv");
 //window.open('data:application/vnd.ms-excel,' + encodeURIComponent( $('div[id$=printable-area]').html()));
  //  e.preventDefault();
 //html_table_to_excel('xlsx');
fnExcelReport('reprt-table-modal');
            });

	function html_table_to_excel(type)
    {
        var data = document.getElementById('printablediv');

        var file = XLSX.utils.table_to_book(data, {sheet: "sheet1"});

        XLSX.write(file, { bookType: type, bookSST: true, type: 'base64' });

        XLSX.writeFile(file, 'file.' + type);
    }

 
		function toExcel(div){

			var a = document.createElement('a');
			//getting data from our div that contains the HTML table
			var data_type = 'data:application/vnd.ms-excel';
			var table_div = document.getElementById(div);
			var table_html = table_div.outerHTML.replace(/ /g, '%20');
			a.href = data_type + ', ' + table_html;
			//setting the file name
			a.download = 'test.xls';
        
			//triggering the function
			a.click();
			
			
			

		 }

function fnExcelReport(divID)
{
    var tab_text="<table border='2px'>";


    
    var textRange; var j=0;
    tab = document.getElementById(divID); // id of table
	var columns = tab.rows[0].length;
var reportHeader = document.getElementById('logo-header').innerHTML;
tab_text = tab_text + "<tr colspan='"+columns+"'>"+reportHeader+"</tr>";
	tab_text = tab_text + "<tr>";

    for(j = 0 ; j < tab.rows.length ; j++) 
    {     
        tab_text=tab_text+tab.rows[j].innerHTML+"</tr>";
        //tab_text=tab_text+"</tr>";
    }

    tab_text=tab_text+"</table>";
    tab_text= tab_text.replace(/<A[^>]*>|<\/A>/g, "");//remove if u want links in your table
    //tab_text= tab_text.replace(/<img[^>]*>/gi,""); // remove if u want images in your table
    tab_text= tab_text.replace(/<input[^>]*>|<\/input>/gi, ""); // reomves input params

    var ua = window.navigator.userAgent;
    var msie = ua.indexOf("MSIE "); 

    if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))      // If Internet Explorer
    {
        txtArea1.document.open("txt/html","replace");
        txtArea1.document.write(tab_text);
        txtArea1.document.close();
        txtArea1.focus(); 
        sa=txtArea1.document.execCommand("SaveAs",true,"File-name.xls");
    }  
    else                 //other browser not tested on IE 11
        sa = window.open('data:application/vnd.ms-excel,' + encodeURIComponent(tab_text));  

    return (sa);
}
        
     // This must be a hyperlink
		$("body").delegate(".exportCSV ","click",function(event){
                // var outputFile = 'export'
                var outputFile = window.prompt("Magac ula bax excel ka") || 'export';
                outputFile = outputFile.replace('.csv','') + '.csv'
                 
                // CSV
                exportTableToCSV.apply(this, [$('#reprt-table-modal'), outputFile]);
                
                // IF CSV, don't do event.preventDefault() or return false
                // We actually need this to be a typical hyperlink
            });

function exportTableToCSV($table, filename) {
                var $headers = $table.find('tr:has(th:not(.hide))')
                    ,$rows = $table.find('tr:has(td:not(.hide))')

                    // Temporary delimiter characters unlikely to be typed by keyboard
                    // This is to avoid accidentally splitting the actual contents
                    ,tmpColDelim = String.fromCharCode(11) // vertical tab character
                    ,tmpRowDelim = String.fromCharCode(0) // null character

                    // actual delimiter characters for CSV format
                    ,colDelim = '","'
                    ,rowDelim = '"\r\n"';

                    // Grab text from table into CSV formatted string
                    var csv = '"';
                    csv += formatRows($headers.map(grabRow));
                    csv += rowDelim;
                    csv += formatRows($rows.map(grabRow)) + '"';

                    // Data URI
                    var csvData = 'data:application/csv;charset=utf-8,' + encodeURIComponent(csv);

                // For IE (tested 10+)
                if (window.navigator.msSaveOrOpenBlob) {
                    var blob = new Blob([decodeURIComponent(encodeURI(csv))], {
                        type: "text/csv;charset=utf-8;"
                    });
                    navigator.msSaveBlob(blob, filename);
                } else {
                    $(this)
                        .attr({
                            'download': filename
                            ,'href': csvData
                            //,'target' : '_blank' //if you want it to open in a new window
                    });
                }

                //------------------------------------------------------------
                // Helper Functions 
                //------------------------------------------------------------
                // Format the output so it has the appropriate delimiters
                function formatRows(rows){
                    return rows.get().join(tmpRowDelim)
                        .split(tmpRowDelim).join(rowDelim)
                        .split(tmpColDelim).join(colDelim);
                }
                // Grab and format a row from the table
                function grabRow(i,row){
                     
                    var $row = $(row);
                    //for some reason $cols = $row.find('td') || $row.find('th') won't work...
                    var $cols = $row.find('td'); 
                    if(!$cols.length) $cols = $row.find('th');  

                    return $cols.map(grabCol)
                                .get().join(tmpColDelim);
                }
                // Grab and format a column from the table 
                function grabCol(j,col){
                    var $col = $(col),
                        $text = $col.text();

                    return $text.replace('"', '""'); // escape double quotes

                }
            }


			$( "body" ).delegate( ".ktc-update-btn-show", "keyup", function() {
            
            	if($(this).val() != ""){
              	  $(this).closest("form").find(".button").removeClass("d-none");
                }else{
                  $(this).closest("form").find(".button").addClass("d-none");
                }
            });

			$( "body" ).delegate( ".ktc-update-btn-show", "change", function() {
            
            	if($(this).val() != ""){
              	  $(this).closest("form").find(".button").removeClass("d-none");
                }else{
                  $(this).closest("form").find(".button").addClass("d-none");
                }
            });


            
            
          $( "body" ).delegate( ".marks", "blur", function() {
            
var tr = $(this).parent();


var txt = $(this).text();
if($.trim(txt) == "" || $.trim(txt) == "0"){
return false;
}
			var max = tr.find(".max_marks").text();
			
			if(parseFloat(txt) > parseFloat(max)){
			$(this).css("color","red");
            tr.find(".ktc-tick").addClass("error");
			$(this).attr("title","Marks must be less than or equal to "+max);
            tr.find(".ktc-tick").attr("title","Marks must be less than or equal to "+max);
            
			return false;

			}
            
            tr.find(".ktc-tick").removeClass("error");
			
tr.find(".ktc-tick").trigger("click");
			$(this).css("color","black");

});

	$("body").delegate(".load_header","change", function(){
var action= $(this).attr("alt");
var data ="sp=34&action="+action+"&co="+co+"&user="+user+"&prm=";
var prm = "";
var rp_frm= $(this).closest("form");


rp_frm.find(".req").each(function(){
if($(this).hasClass("ktc-autocomplete")){
var  val = $(this).closest(".ktc-form-box").find(".hidden-auto").val();
prm+=","+$.trim(val);
}else{
prm+=","+$.trim($(this).val());
}

});
prm = prm.substring(1, prm.length)
data  += prm;
        
  //      alert(data);
    
$.post("/forms/reportHeader",data,function(res){
//alert(res);
$("#report-header2").html(res);
});

});

	$("body").delegate(".load_footer","change", function(){
var action= $(this).attr("alt2");
var data ="sp=428&action="+action+"&co="+co+"&user="+user+"&prm=";
var prm = "";
var rp_frm= $(this).closest("form");


rp_frm.find(".req").each(function(){
if($(this).hasClass("ktc-autocomplete")){
var  val = $(this).closest(".ktc-form-box").find(".hidden-auto").val();
prm+=","+$.trim(val);
}else{
prm+=","+$.trim($(this).val());
}

});
prm = prm.substring(1, prm.length)
data  += prm;
        
    //   alert(data);
    
$.post("/forms/reportFooter",data,function(res){
//alert(res);
$("#report-footer2").html(res);
});

});

$("body").delegate(".ktc-print_invoice","click", function(e){
e.preventDefault();
var url = $(this).attr("href");

loadOtherPage(url) ;
});


function loadOtherPage(url) {

    $("<iframe>")                             // create a new iframe element
        .hide()                               // make it invisible
        .attr("src", url) // point the iframe to the page you want to print
        .appendTo("body");                    // add iframe to the DOM to cause it to load the page

}

})