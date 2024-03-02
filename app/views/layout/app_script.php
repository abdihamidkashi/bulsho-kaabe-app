<button type="button" class="btn btm bg-success text-white"  data-toggle="modal" data-target="#contact-modal">
                                    <i class="fa fa-whatsapp"></i> 
                                </button>
 
                                
     <div class="absolute bg-dark  <?php echo $hidec;?> footer-links" style="width:100% !important">
        <?php  $url =  str_replace("url=", "",$_SERVER['QUERY_STRING']);?>
     <ul class="nav nav-pills  bg-dark "  style="width:100% !important">
         <li class="nav-item text-center" style="">
      <a class="nav-link <?php echo strpos($url, 'portal/index') !== false  ? 'active' : '';?>" href="<?php echo URLROOT;?>/portal/index"><i class="fa fa-home fa-lg"></i><br/>Home</a>
    </li>
    <!--
    <li class="nav-item text-center" style="">
      <a class="nav-link <?php echo $url == 'portal/free' ? 'active' : '';?>" href="<?php echo URLROOT;?>/portal/free"><i class="fa fa-user-md fa-lg"></i> <br/>Dhaqaatiirta </a>
    </li>
   -->
     <li class="nav-item text-center d-none" style="">
      <a class="nav-link  <?php echo $url == 'agent/index' ? 'active' : '';?>" href="<?php echo URLROOT;?>/agent/index"><i class="fa fa-user fa-lg"></i><br/>Profile</a>
    </li>
   
    <li class="nav-item text-center d-none" style="">
      <a class="nav-link <?php echo $url == 'portal/faqs' ? 'active' : '';?>" href="<?php echo URLROOT;?>/portal/faqs"><i class="fa fa-question fa-lg"></i><br/>Support</a>
    </li>
   
 
 
  </ul>
  </div>   
  
  <?php  require_once("../app/views/portal/contact_modal.php");?>
   
    <!-- JavaScript Libraries -->
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/jquery.min.js"></script>
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/jquery-migrate.min.js"></script>
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/easing.min.js"></script>
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/hoverIntent.js"></script>
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/superfish.min.js"></script>
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/wow.min.js"></script>
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/venobox.min.js"></script>
 <script src="//code.tidio.co/70a9xteq0pepmbq71duylehfzwajtqeg.js" async></script>

  <!-- Template Main Javascript File -->
  <script src="<?php echo URLROOT;?>/app_files/vendor/bootstrap/js/menu-main.js"></script> 
   
   <script>
   var URLROOT = 'https://bk.bulshotech.com';
       $(".hospital-box").click(function(e){
         
          if(e.target.id == 'save-sms'){
              $(this),trigger("click");
              return;
          }
          
         $(this).css("background-color", "lightblue");
          
          var id = $(this).attr("id");
        var data = "sp=564&token="+$("#visitor-token").text()+"&id="+id+"&action=hospital";
        var url = URLROOT+"/portal/save2";
        
        $.post(url, data, function(res){
           // alert(res);
             window.location.href = URLROOT+'/portal/hospitaldoctor/'+id;
        })
          
          
       });
      
      
       $(".doctor-box").click(function(){
             $(this).css("background-color", "lightblue");
           var id = $(this).attr("id");
           var hospital = $(this).attr("alt");
            var data = "sp=564&token="+$("#visitor-token").text()+"&id="+id+"&action=doctor";
        var url = URLROOT+"/portal/save2";
        
        $.post(url, data, function(res){
           // alert(res);
            window.location.href = URLROOT+'/portal/patient/'+hospital+'/'+id;
        })
           
       });
      
      
      $("#ticket-order").submit(function(e){
          e.preventDefault();
          
          $("#order-btn").attr("disabled", true);
          
          $(".payment-msg").removeClass("d-none");
          $(".patient-box").addClass("d-none");
          
          var data = $(this).serialize();
          var url = $(this).attr("action");
          
          $.post(url, data, function(res){
            //  alert(res);
               $("#order-btn").attr("disabled", false);
               
               $(".payment-msg").addClass("d-none");
          $(".patient-box").removeClass("d-none");
          
          var res = res.split("|");
          
          $(".msg-placeholder").addClass("alert alert-"+res[0]);
          $(".msg-placeholder").html(res[1]);
          
          
          })
         }) 
         
         
           $("#search").on("keyup", function() {
    var value = $(this).val().toLowerCase();
    $(".search-box").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
    
    $("#filtered-result").html($(".search-box:visible").length + ' ayaa lasoo helay');
  });
  
  $(".select-department").change(function(){
        var value = $(this).val().toLowerCase();
    $(".search-box").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
    });
     $("#filtered-result").html($(".search-box:visible").length + ' ayaa lasoo helay');
  })
  
  function save_sms(url){
      
 $.get(url, function(res){
 alert(res);
 });
  }
  
  
        $(".save-sms").click(function(e){
           // e.preventDefault();
 	var url = $(this).attr('alt');
 	//alert(url);
 $.get(url, function(res){ 
    window.location.href = res;
 });
 });
 
 $(".show-more").click(function(e){
     e.preventDefault();
     $(".more-text").removeClass("d-none");
     $(this).addClass("d-none")
 });
 $(".show-less").click(function(e){
     e.preventDefault();
     $(".more-text").addClass("d-none");
      $(".show-more").removeClass("d-none")
 });
 
 
 $(".join-campaign").click(function(){
     
     var url = $(this).attr("href");
     var btn = $(this);
     
       btn.attr("disabled", true);
     $.get(url, function(res){
        
             btn.text(res);
       
     })
 })
       
   </script>
    </body>
    </html>