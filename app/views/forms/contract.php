<?php 
$c = $data['contract'];
?>
<style>
    h3,h4{
       font-weight:bold; text-decoration: underline;  
    }
    *{
        font-family: 'Times New Roman (Headings CS)';
        
    }
    
    p, il{
        font-size: 13px;
    }
    
    strong{
        font-weight: bold;
    }
    
    tr{
        margin-bottom: 5px;
    }
</style>
<br/>
<div class="container" style="border: 2px solid #000; padding:15px; ">
    <br/>
    <div class="row">
        <div class="col-6">
            <center>
            <img src="<?php echo URLROOT. '/' . $c->bulsho_logo;?>" width="80px"/>
            <h4>Bulsho Tech</h4>
            </center>
        </div>
        <div class="col-6">
            <center>
            <img src="<?php echo URLROOT. '/' . $c->logo;?>"  width="80px"/>
            <h4><?php echo  $c->hospital;?></h4>
            </center>
        </div>
        
    </div>
    <h2 style="text-align:center; font-weight:bold; text-decoration: underline;">Heshiis-ka eTicket Hospital</h2>
    <hr/>
<h5>Kani waa heshiis u dhaxeeya Shirkadda <strong> Bulsho Tech</strong> Adeeg bixiye iyo <strong><?php echo $c->hospital;?></strong> qaataha adeega</h4>

<h3>Qeexidda Heshiis-ka</h3>
<p><strong>Bulsho Tech</strong> waa shirkadda bixineysa Adeega ka diiwaangashan una hogaansan shuruucda <?php echo $c->state_country;?>, kana howlgasha <?php echo $c->bulsho_address;?></p>
<p><strong><?php echo $c->hospital;?></strong> waa isbitaal-ka qaadanaya Adeega kana diiwaangashan una hogaansan shuruucda <?php echo $c->state_country;?>, kana howlgasha <?php echo $c->city . ' '. $c->region;?></p>
<p><strong>eTicket Hospital</strong> waa adeega ay bixineyso Bulsho tech siineysanana <?php echo $c->hospital;?>, Adeegana Waa App lagu shubanayo moobeylada, wuxuuna isbitaalka u fududeynayaa in bukaanadu hab online ah uga soo dalbdaan Ticket-ka isbitaalka, sidoo kalana uu ka helayo xogta dhammaan dhakhaatiirta iyo adeegyada caafimaad ee isbitaalka</p>

<h3>Baaxadda Adeegyada</h3>
<p>Bulsho Tech waxay u qabanaysaa <?php echo $c->hospital;?> qodobada hoos ku xusan</p>
<ol>
    <li><?php echo $c->hospital;?> waxaa lagu darayaa liiska Isbitaalada App-ka Bulsho Tech</li>
    <li><?php echo $c->hospital;?> wuxuu App-ka ku diiwaangashanayaa dhakhaatiirta iyo adeegyada caafimaad ee isbitaal-ku bixiyo</li>
     <li><?php echo $c->hospital;?> wuxuu App-ka gelinayaa qiimaha Ticket-ka isbitaal-ka iyo dhakhaatiirtaba</li>
    <li><?php echo $c->hospital;?> wuxuu la soconayaa xogta bukaanada soo dalbatay adeegyada isbitaal-ka</li>
    <li>Hadii isbitaal-ka <?php echo $c->hospital;?> uu leeyahay Database u gaar ah waxaan siineynaa API u fududeynaya isku xirka App-ka iyo Database-ka</li>
    <li>Haddii uu bukaan soo dalbado adeegyada isbitaal-ka, markiiba waxaa usoo dhacaysa isbitaal-ka fariin wargelin ah</li>
   
    
</ol>
<h3>Kharashaad-ka Adeega</h3>
<p>Kharashaad-ka adeegan wuxuu u qeybsan yahay 2 qeybood oo hoos ku xusan</p>
<h4>Qeybta 1<sup>aad</sup></h4>
<ol>
<li>Bulsho Tech wax kharashaad ah kama dooneyso <?php echo $c->hospital;?> 
<li>Sidoo kalana isbitaal-ka wax kharash ah kama qaadanayo Bulsho Tech</li>
<li>Bulsho Tech waxay khidmad lacageed oo dhan $3 ka qaadeysaa bukaanka App-ka ka soo dalbada Ticket-ka isbitaal-ka</li>
<li>Sidoo Bukaanka wuxuu bixinayaa  ticket-ka isbitaal-ka oo dhan <?php echo $c->currency . ' '. $c->ticket_fee  ;?></li>
<li>Bukaanka wuxuu bixinayaa isku darka lacagta khidmadda iyo ticket-ka isbitaal-ka oo dhan <?php echo $c->currency . ' '. ($c->ticket_fee + 3);?></li>
</ol>
 
<h4>Qeybta 2<sup>aad</sup></h4>
<ol>
    <li><?php echo $c->hospital;?>  wuxuu bixinayaa kharasha dhan <?php echo $c->currency . ' ' . $c->commission_fee;?> Tickit walba oo App-ka lagasoo dalbado</li>
    <li>Bulsho Tech waxay khidmad lacageed oo dhan <?php echo $c->currency .' ' . $c->service_fee;?> ka qaadeysaa bukaan walba oo App-ka kasoo dalbada Ticket</li>
     <li>Sidoo kale Bukaanka wuxuu bixinayaa  ticket-ka isbitaal-ka oo dhan <?php echo $c->currency . ' '. $c->ticket_fee  ;?></li>
    <li>Bukaanka wuxuu bixinayaa isku darka lacagta khidmadda iyo ticket-ka isbitaal-ka oo dhan <?php echo $c->currency . ' '. ($c->ticket_fee + $c->service_fee);?></li>
</ol>
<p>Haddaba Bulsho Tech iyo <?php echo $c->hospital;?> waxay ku wada shaqeynayaan Kharashaad-ka adeega qodobadiisa <?php echo $c->commission_fee > 0 ? ' <strong>Qeybta 2<sup>aad</sup></strong>' : ' <strong>Qeybta 1<sup>aad</sup></strong>';?>  </p>

<h3>Hab-ka bixinta Kharashaad-ka</h3>
<ol>
    <li>Bukaan walba oo Ticket-ka isbitaal-ka kasoo dalbada App-ka wuxuu lacagta Ticket-ka ku shubayaa Akoon-ka Bulsho Tech si otomatic ah</li>
    <li>Bulsho tech waxay bukaan-ka siineysaa Warqad lacag qabasho iyo Ticket wada socdo</li>
    <li>Isbitaal-ku wuxuu keydsanayaa warqadaha Lacag bixinta ee Bukaan-ka u keeno</li>
    <li>Bulsho Tech waxay isbitaal-ka ku wareejinaysaa wadarta lacagaha Ticket-ka maalin walba laga soo dalbado App-ka</li>
    
</ol>
<h3>Joojinta Heshiiska</h3>
<p>Heshiis-kan waxaa joojin kara mid kamid ah labada dhinac ee kala aha Bulsho Tech iyo <?php echo $c->hospital;?>, iyadoo lasoo gudbinayo qoraal cadeynaya sababaha loo joojinayao.</p>

<h3>Dhaqan gal-ka heshiiska</h3>
<p>Heshiis-kan wuxuu dhaqan galayaa laga bilaabo maalin-ka labada daraf ee heshiisku ka dhexeeyo wada saxiixaan, wuxuuna joogsan doonaa heshiis-kan marka labada dhinac isla gartaan in la joojiyo</p>

<div class="row">
    <div class="col-6">
        <table width="100%">
            <tr>
                <th colspan="2"><center>Saxiixa Bulsho Tech</center><br/></th>
                 
            </tr>
            <tr>
                <td>Magaca</td>
                <td>__________________________________________________</td>
            </tr>
            <tr>
                <td>Jagada</td>
                <td>__________________________________________________</td>
            </tr>
            <tr>
                <td>Taariikhda</td>
                <td>__________________________________________________</td>
            </tr>
              <tr>
                <td>Saxiixa</td>
                <td>__________________________________________________</td>
            </tr>
            
        </table>
    </div>
    <div class="col-6" >
        <table width="100%"  >
            <tr>
                <th colspan="2"><center>Saxiixa <?php echo $c->hospital;?></center><br/></th>
                 
            </tr>
            <tr>
                <td>Magaca</td>
                <td>__________________________________________________</td>
            </tr>
            <tr>
                <td>Jagada</td>
                <td>__________________________________________________</td>
            </tr>
            <tr>
                <td>Taariikhda</td>
                <td>__________________________________________________</td>
            </tr>
            <tr>
                <td>Saxiixa</td>
                <td>__________________________________________________</td>
            </tr>
            
        </table>
    </div>
    
</div>



</div>    
    
 <br/>   
<!--
Here's a draft billing contract template between Kaafi as a service provider and Ishabiyaha as a service receiver:

Billing Contract

This billing contract ("Contract") is made and entered into on [date] by and between:

Kaafi, a company incorporated under the laws of [state/country], with its principal place of business at [address] (hereinafter "Service Provider"); and
Ishabiyaha, a company incorporated under the laws of [state/country], with its principal place of business at [address] (hereinafter "Service Receiver").
The Service Provider and the Service Receiver hereby agree as follows:

Scope of Services
The Service Provider will provide the following services to the Service Receiver: [list of services].
Term
This Contract will commence on [start date] and will continue until terminated by either party upon [notice period] written notice.
Fees
The Service Receiver will pay the Service Provider the following fees for the services specified in this Contract: [fees and payment schedule].
Expenses
The Service Receiver will reimburse the Service Provider for any reasonable out-of-pocket expenses incurred in connection with the performance of services under this Contract.
Confidentiality
The Service Provider will maintain the confidentiality of all information provided by the Service Receiver in connection with this Contract.
Termination
Either party may terminate this Contract at any time upon written notice if the other party breaches any material term or condition of this Contract.
Governing Law
This Contract will be governed by the laws of the State of [state].
Dispute Resolution
Any disputes arising out of or in connection with this Contract will be resolved through [mediation/arbitration/litigation].
IN WITNESS WHEREOF, the parties have executed this Contract as of the date and year first above written.

Service Provider:
[Your Name]
[Title]
[Company Name]

Service Receiver:
[Your Name]
[Title]
[Company Name]
-->