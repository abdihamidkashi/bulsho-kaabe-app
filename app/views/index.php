  <!--app-content open-->
				<div class="app-content">
					<div class="side-app">

						<!-- PAGE-HEADER -->
						<div class="page-header">
							<div>
								<h1 class="page-title">Dashboard / لوحة القيادة</h1>
								<ol class="breadcrumb">
									<li class="breadcrumb-item"><a href="#">Home</a></li>
									<li class="breadcrumb-item active" aria-current="page">Dashboard </li>
								</ol>
							</div>
							<div class="ms-auto pageheader-btn ">
								<a href="<?php echo URLROOT;?>/users/enable2FA" class="btn btn-primary btn-icon text-white me-2 <?php echo @$_SESSION['is_enable_2fa']==1 ? 'd-none' : '';?>">
									<span>
										<i class="fe fe-plus"></i>
									</span> Enable 2 Factor Authentication
								</a>
								<a href="#" class="btn btn-success btn-icon text-white d-none">
									<span>
										<i class="fe fe-log-in"></i>
									</span> Export
								</a>
							</div>
						</div>
						<!-- PAGE-HEADER END -->

						<!-- ROW-1 -->
						<div class="row">
							<div class="col-lg-12 col-md-12 col-sm-12 col-xl-12">
								<div class="row">
								     <?php
								     
								     foreach($data['chart'] as $chart){?>

									<div class="col-lg-6 col-md-12 col-sm-12 col-xl-3">
										<div class="card overflow-hidden">
											<div class="card-body">
												<div class="row">
													<div class="col">
														<h6 class="">	<?php echo $chart->description;?></h6>
														<h3 class="mb-2 number-font"><?php echo $chart->count_number;?></h3>
														<p class="text-muted mb-0">
												<?php echo $chart->count_number;?> - 			
													<?php echo $chart->description;?>	
														</p>
													</div>
													<div class="col col-auto">
														<div class="counter-icon bg-primary-gradient box-shadow-primary brround ms-auto">
															<i class="<?php echo $chart->icon;?> text-white mb-5 "></i>
														</div>
													</div>
												</div>
											</div>
										</div>
									</div>
									<?php }  ?>
									
								</div>
							</div>
						</div>
						 
 

