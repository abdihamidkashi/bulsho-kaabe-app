 <!-- JQUERY JS -->
		<script src="<?php echo URLROOT;?>/js/jquery.min.js"></script>
        <script src="<?php echo URLROOT;?>/ktc/js/core.js?1.17"></script>
<script type="text/javascript" src="https://unpkg.com/xlsx@0.15.1/dist/xlsx.full.min.js"></script>

		<!-- BOOTSTRAP JS -->
		<script src="<?php echo URLROOT;?>/plugins/bootstrap/js/popper.min.js"></script>
		<script src="<?php echo URLROOT;?>/plugins/bootstrap/js/bootstrap.min.js"></script>

		<!-- SPARKLINE JS-->
		<script src="<?php echo URLROOT;?>/js/jquery.sparkline.min.js"></script>

	
		<!-- INTERNAL SELECT2 JS -->
		<script src="<?php echo URLROOT;?>/plugins/select2/select2.full.min.js"></script>

		<!-- INTERNAL Data tables js-->
		<script src="<?php echo URLROOT;?>/plugins/datatable/js/jquery.dataTables.min.js"></script>
		<script src="<?php echo URLROOT;?>/plugins/datatable/js/dataTables.bootstrap5.js"></script>
		<script src="<?php echo URLROOT;?>/plugins/datatable/dataTables.responsive.min.js"></script>

		<!-- ECHART JS-->
		<script src="<?php echo URLROOT;?>/plugins/echarts/echarts.js"></script>

		<!-- SIDE-MENU JS-->
		<script src="<?php echo URLROOT;?>/plugins/sidemenu/sidemenu.js"></script>

		<!-- SIDEBAR JS -->
		<script src="<?php echo URLROOT;?>/plugins/sidebar/sidebar.js"></script>

	
		
	
		<!-- CUSTOM JS -->
		<script src="<?php echo URLROOT;?>/js/custom.js"></script>
		<script src="//cdn.ckeditor.com/4.10.0/full/ckeditor.js"></script>

<script>
    $(document).ready(function(){


$(".theme-layout").click(function(){
    var theme = "light-mode";
    if($("body").hasClass("dark-mode")){
    	theme = "dark-mode";
    }
    
    
    var url = "<?php echo URLROOT;?>/dashbaord/theme/"+theme;
    //alert(url);
    $.post(url,function(res){
    	//alert(res);
    });
    });
 	
     $('[data-toggle="popover"]').popover();   
            $(".first-link").each(function(){
                var cat_icon = $(this).attr("main");
                var sub_cat_icon = $(this).attr("sub");
                //alert(cat_icon + sub_cat_icon);
                //alert($(this).closest(".slide").text());
               // return false;
            $(this).closest(".slide").find(".main").addClass(cat_icon);
            $(this).closest(".sub-slide").find(".sub").addClass(sub_cat_icon);
                
            });

        $(".link.active").closest(".sub").addClass("active");
        $("#visitorModal").modal("show");
        
        
        $(".exam").click(function(e){
            e.preventDefault();
            
            if($(this).hasClass("in-active")){
                alert("Imtixaanka maadadan waqtigeeda lama gaarin ama waala dhaafay, fadlan hubi waqtiga mahadsanid");
            }else{
                 window.location.href = $(this).attr("href");
            }
        
        })
        
        $(".answers").click(function(){
            if(confirm("Ma hubtaa inaad ka jawaabtay dhammaan su'aalaha imtixaankan?")){
                
                $(this).attr("disabled", true);
                $(this).text("Wax yat sug ....");
                
                
                $(".answer-form").each(function(){
                    $(this).submit();
                });
                
                
                
                setTimeout(function(){
                    alert("Waad ku mahadsantahay ka qeyb galkaaga imtixaanka, natiijada imtixaanka dhawaan ayaa la shaacin doonaa");
                    window.history.back();
                  }, 5000);
                
            }
        });
        
       $(".answer-form").submit(function(e){
           e.preventDefault();
           var data = $(this).serialize();
           var url = $(this).attr("action");
           
          // alert(data);
           
           $.post(url,data, function(res){
              // alert(res);
           })
           
           
       });
       
       $(".video").on("pause", function (e) {
  alert("Video paused. Current time of videoplay: " + e.target.currentTime );
});

 

 

$("#search-tell").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $("#visitors tr").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
  });
  
  $(".bp-video").click(function(){
      alert(1);
  });
  
  $("body").delegate(".colorize", "click",function(){
      $(this).css("color", "green");
     
      
  });
  
  

 	$("body").delegate(".quick-link", "click",function(e){
    
    e.preventDefault();
    
    if($(this).hasClass("show")){
    	 $(".quick-label").addClass("d-none");
        $(this).removeClass("show");
    
    }else{
   
$(".quick-label").removeClass("d-none");
    $(this).addClass("show");
    }
    
    
    });
 
 
 	$(".activate-menu").closest(".slide").addClass("is-expanded");
 	$(".activate-menu").closest(".slide").find(".side-menu__item").addClass("active");
 
 var all_link = "";
        $(".ktc-link").each(function(){
            all_link+= "<li>" + $(this).parent().html() +"</li>";
        });
        
        $(".search-menu").html(all_link);
 
 $("body").delegate(".search-link","keyup",function(e){
    if($(this).val() == ""){
        $(".search-menu-parent").addClass("d-none");
      $(".main-menu").removeClass("d-none");
    
    return false;
    }
    $(".main-menu").addClass("d-none");
    $(".search-menu-parent").removeClass("d-none");
    
     var value = $(this).val().toLowerCase();
     var count = "0";
    $(".search-menu li").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
     
    });
    
     count = $(".search-menu li:visible").length;
    
    
    $(".filter-count").text(count);
    
});
 $("body").delegate(".save-sms","click",function(e){
 	var url = $(this).attr('alt');
 $.get(url, function(res){
// alert(res);
 });
 });
 
 //alert($("#passcard").height());
 
 $(".coming-soon").click(function(e){
 e.preventDefault();
 alert("Dhawaan ayaa laga shaqeysiin doonaa");
 });
       CKEDITOR.replace('editor');

    });
    </script>
	</body>
</html>
 