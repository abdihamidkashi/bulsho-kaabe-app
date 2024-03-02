<body class="signup-page">
    <div class="signup-box">
        <div class="logo">
            <a href="javascript:void(0);">OHTICKET<b>.COM</b></a>
            <small>Online Hospital Ticket System - Powered Bulsho Tech</small>

        </div>
        <div class="card">
            <div class="body">
                <form id="sign_up" method="POST" class="ktc-form ktc-form-create" action="<?php echo URLROOT;?>/users/register" enctype="multipart/form-data">
                    <input type="hidden" value="2" name="sp"/>
                    <div class="msg">Register a new hospital</div>
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">home</i>
                        </span>
                        <div class="form-line">
                            <input type="text" class="form-control" name="hospital" placeholder="Hospital Name" required autofocus>
                        </div>
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">map</i>
                        </span>
                        <div class="form-line">
                            <input type="text" class="form-control" name="address" placeholder="Hospital Address" required >
                        </div>
                    </div>
                    
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">email</i>
                        </span>
                        <div class="form-line">
                            <input type="email" class="form-control" name="email" placeholder="Hospital Email Address" required>
                        </div>
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">home</i>
                        </span>
                        <div class="form-line">
                            <input type="text" class="form-control" name="domain" placeholder="Hospital Domain name.bulshotech.com" required>
                        </div>
                    </div>
                    
                            <input type="hidden" class="" name="lh" value="">
                    
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">home</i>
                        </span>
                        Hospital Logo
                        <div class="form-line">
                            <input type="hidden" value="logo" name="_next_upload_logo"/>
                            <input type="file" class="form-control" name="logo" placeholder="Logo" required>
                        </div>
                    </div>
                    
                    <input type="hidden" class="" name="us" value="0">

                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">person</i>
                        </span>
                        <div class="form-line">
                            <input type="text" class="form-control" name="admin" placeholder="Hospital Admin Name" required >
                        </div>
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">map</i>
                        </span>
                        <div class="form-line">
                            <input type="text" class="form-control" name="tell" placeholder="Reception WhatsApp Tell eg. 252615190777" required >
                        </div>
                    </div>
                    
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">email</i>
                        </span>
                        <div class="form-line">
                            <input type="email" class="form-control" name="username" placeholder="Username must be anEmail" required>
                        </div>
                    </div>
                    
                    
                    
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">lock</i>
                        </span>
                        <div class="form-line">
                            <input type="password" class="form-control" name="password" minlength="6" placeholder="Password" required>
                        </div>
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">lock</i>
                        </span>
                        <div class="form-line">
                            <input type="password" class="form-control" name="confirm" minlength="6" placeholder="Confirm Password" required>
                        </div>
                    </div>
                    
                    
                    <input type="hidden" class="" name="date" value="<?php echo date('Y-m-d');?>">
                    <input type="hidden" class="" name="cotype" value="hospital">

                    
                    <div class="form-group">
                        <input type="checkbox"  id="terms" class="filled-in chk-col-pink">
                        <label for="terms">I read and agree to the <a href="<?php echo URLROOT;?>/users/terms" target="_blank">terms of usage</a>.</label>
                    </div>

                    <button class="btn btn-block btn-lg bg-pink waves-effect" type="submit">SIGN UP</button>

                    <div class="m-t-25 m-b--5 align-center">
                        <a href="<?php echo URLROOT;?>/users/login">You already have a membership?</a>
                    </div>
                </form>
                <div ></div>
                <?php if(isset($data['result']->msg)){
                        $msg = explode("|", $data['result']->msg)
                    ?>
                   <div class="alert alert-<?php echo $msg[0];?>">
                       <strong><?php echo @$msg[0];?></strong> <?php echo @$msg[1];?>
                   </div> 
                   <?php } ?>
                
            </div>
        </div>
    </div>
    
    
