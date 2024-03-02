<body class="login-page">
    <div class="login-box">
        <div class="logo">
            <a href="javascript:void(0);"><b><?php echo $data['company']->name;?></b></a>
            <small><?php echo $data['company']->name;?></small>

        </div>

        <div class="card">
            <div class="body">
                <form id="sign_in" method="POST" action="<?php echo URLROOT;?>/forms/save" class="ktc-form ktc-form-create">
                     <input type="hidden" name="sp" value="7" readonly />
                     

                    <div class="msg">Enter your email and New Password</div>
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">person</i>
                        </span>
                        <div class="form-line">
                            <input type="text"  class="form-control" name="username" value="" placeholder="Email Address" required autofocus>
                        </div>
                    </div>
                    
                     <input type="hidden" name="token" value="<?php echo $data['token'];?>" readonly/>

                    
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">lock</i>
                        </span>
                        <div class="form-line">
                            <input type="password" class="form-control" value="" name="password" placeholder="New Password" required>
                        </div>
                    </div>
                    
                    <div class="input-group">
                        <span class="input-group-addon">
                            <i class="material-icons">lock</i>
                        </span>
                        <div class="form-line">
                            <input type="password" class="form-control" value="" name="password2" placeholder="Confirm Password" required>
                        </div>
                    </div>
                    
                    <input type="hidden" name="co" value="<?php echo $data['company']->id;?>" readonly/>

                    
                    <div class="row">
                        <div class="col-xs-6 p-t-5">
                            
                        </div>
                        <div class="col-xs-6">
                            <button class="btn btn-block bg-pink waves-effect" type="submit">Change Password</button>
                        </div>
                    </div>
                    <div class="row m-t-15 m-b--20">
                        <div class="col-xs-6">
                            <a href="<?php echo URLROOT;?>/users/register">Register Now!</a>
                        </div>
                        <div class="col-xs-6 align-right">
                            <a href="<?php echo URLROOT;?>/users/login">Back to Login</a>
                        </div>
                    </div>
                   
                   
                  
                </form>
                <div class="">
                      
                   </div> 
            </div>
        </div>
    </div>