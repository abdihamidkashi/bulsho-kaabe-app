<style>
  .payment-msg{
      width: 100% ;
      height: 700px;
      padding-top: 70%;
      background-color: #999;
      z-index : 999999;
      text-align: center;
      color: white;
      font-weight: bold;
      font-size: 23px;
  }  
  
  .required {
      color: red;
  }
</style>

	<div class="limiter">
	    <div class="payment-msg d-none">Fadlan fiiri taleefanka aad lacagta ka bixineyso oo soo geli Pin-ka Zaad-ka</div>
	   <?php $d = $data['doctor'][0];?>
		<div class="container patient-box" >
         <br/>
	    <h5 style="color:blue; font-weight:bold"><center><?php echo $d->hospital;?></center></h5>
	    <hr/>
           <div class="doctor-box" id="<?php echo $d->auto_id;?>"  style="border-bottom: 1px solid #666;margin-bottom:3px;">
               <div class="row"  style=" margin-bottom:3px;">
                   <div class="col-2"  >
                   <img src="<?php echo $d->doctor_image == 'error' ? URLROOT . '/'. $d->department_image :  URLROOT . '/'. $d->doctor_image;?>"   style="width:55px; height:55px;border:1px solid #666;border-radius:50%"/>
                   </div>
                    <div class="col-10"  >
                   <p   style="margin:3px !important"> <strong><?php echo $d->doctor;?></strong> <br/> <small><?php echo $d->department . ' - Ticket fee : '. $d->ticket_fee . ' + ' . $d->service_fee . ' = ' . $d->total_fee;?></small> </p>
                   
                   </div>
               </div>
           </div> 
           
           
            <center><h3>Foom-ka Bukaanka</h3></center>
            <p><small>Kusoo dhawoow App-ka Dalbashada Ticket-ka Isbitaalada ee <b>BULSHO KAABE</b>, Qiimaha Ticket-ka Isbitaalka <?php echo $d->hospital;?> waa <?php echo $d->ticket_fee;?>, Lacagta khidmadda ee Bulsho Kaabe waa <?php echo $d->service_fee;?>, Wadarta guud waa <?php echo $d->total_fee;?></small></p>
  <form action="<?php echo URLROOT;?>/portal/checkout" method="POST" id="ticket-order">
      <input type="hidden" name="sp" value="538"/>
      <input type="hidden" name="com" value="1"/>
      <input type="hidden" name="hos" value="<?php echo $d->hospital_id;?>"/>
      <input type="hidden" name="doc" value="<?php echo $d->auto_id;?>"/>
      
    <div class="form-group">
      <label for="name">Magaca Bukaanka <span class="required">*</span> :</label>
      <input type="text" class="form-control" id="name" required autofocus placeholder="Magaca Bukaanka oo seedexan" name="name">
    </div>
    <div class="form-group">
      <label for="gender">Jinsiga Bukaanka <span class="required">*</span> :</label>
      <select   class="form-control" id="gender" required name="gender">
          <option value="">Dooro Jinsi</option>
          <option value="Male">Lab</option>
          
          <option value="Female">Dhedig</option>
          
      </select>
    </div>
    
    <div class="form-group">
        <div class="row">
           
           
            <div class="col-4">
             <label for="day">Taarikhda<span class="required">*</span>:</label>
             <select class="form-control"   id="day" required name="day">
                 <option value="">Maalinta</option>
                 <?php for($i = 1; $i <= 31; $i++){?>
                 <option value="<?php echo $i;?>"><?php echo $i;?></option>
                 <?php } ?>
             </select>
          </div>
          
           <div class="col-4">
             <label for="mnth">Dhalashada<span class="required">*</span>:</label>
             <select  class="form-control"  id="mnth" required   name="mnth">
                  <option value="">Bisha</option>
                  <?php for($i = 1; $i <= 12; $i++){?>
                 <option value="<?php echo $i;?>"><?php echo $i;?></option>
                 <?php } ?>
             </select>
          </div>
          
           <div class="col-4">
             <label for="year">Bukaanka <span class="required">*</span>:</label>
             <select  class="form-control"  id="year" required  name="year">
                  <option value="">Sanadka</option>
                  <?php
                  $y = date("Y");
                  $y2 = $y - 100;
                  for($i = $y; $i >= $y2; $i--){?>
                 <option value="<?php echo $i;?>"><?php echo $i;?></option>
                 <?php } ?>
             </select>
          </div>
         </div>
    </div>
    
    <div class="form-group">
      <label for="mother">Magaca Hooyada Bukaanka:</label>
      <input type="text" class="form-control" id="mother"  placeholder="Hooyada Bukaanka" name="mother">
    </div>
    
     <div class="form-group">
      <label for="address">Deegaanka Bukaanka <span class="required">*</span>:</label>
      <input type="text" class="form-control" id="addresss" required placeholder="Deegaanka Bukaanka" name="address">
    </div>
    
    <div class="form-group">
      <label for="tell">Tell-ka Bukaanka <span class="required">*</span> :</label>
      <input type="number" class="form-control" id="tell" required placeholder="Tell-ka Bukaanka" name="tell">
    </div>
    
   
    
     <div class="form-group">
      <label for="payment_tell">Tell-ka Lacagta laga jarayo <span class="required">*</span>:</label>
      <input  style="border: 1px solid red" type="number" class="form-control" id="payment_tell" required placeholder="Tell-ka Lacagta laga jarayo" name="payment_tell">
      <span style="color:red"><small>Fadlan ku qor tell-ka aad lacagta Dhaqtar-ka iyo khidmaddaba ka bixieyso oo dhan <?php echo $d->total_fee;?></small></span>
    </div>
    
    <input type="hidden1" name="amount" value="<?php echo $d->total_fee_with_no_currency;?>"/>
    <input type="hidden" name="description" value="<?php echo  $d->department . '-'. $d->hospital;?>"/>
    
    
    <button type="submit" class="btn btn-primary btn-block" id="order-btn">Dalbo oo bixi Lacagta</button>
    
  </form>
      <div class="msg-placeholder" >
          
      </div>
      <br/><br/><br/><br/>
 </div>
 </div>
