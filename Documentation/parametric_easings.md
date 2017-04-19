### Supported Parametric Curves

These are the supported parametric curves that you can apply to the property animation. A good reference for some of the supported parametric curves can be found [here](http://easings.net/)


<table>
  <tbody>
    <tr>
      	<td>
       		InSine<br>
       		InOutSine<br>
       		OutSine<br>
       		OutInSine</td>
      	<td>
       		InQuadratic<br>
       		InOutQuadratic<br>
       		OutQuadratic<br>
      		OutInQuadratic</td>
   	  	<td>
   	  		InCubic<br>
   	  		InOutCubic<br>
   	  		OutCubic<br>
   	  		OutInCubic</td>
    </tr>
    <tr>    
      	<td>
      		InQuartic<br>
      		InOutQuartic<br>
      		OutQuartic<br>
      		OutInQuartic</td>
      	<td>
      		InQuintic <br>
      		InOutQuintic<br>
      		OutQuintic<br>
      		OutInQuintic</td>
      	<td>
    		InExponential<br>
     		InOutExponential<br>
    		OutExponential<br>
    		OutInExponential</td>
    </tr>
    <tr>
      	<td>
      		InCircular <br>
      		InOutCircular<br>
      		OutCircular<br>
      		OutInCircular</td>
    	<td>
    		InBack <br>
    		InOutBack<br>
    		OutBack<br>
    		OutInBack</td>
    	<td>
    		InElastic <br>
    		InOutElastic<br>
    		OutElastic<br>
    		OutInElastic </td>
      </tr>
    <tr>
      <td>
     		InBounce<br>
     		InOutBounce<br>
      		OutBounce<br>
      		OutInBounce</td>
      <td>
          	InAtan<br>
    		InOutAtan<br>OutAtan<br>*</td>
      <td>	
      		Linear<br>
      		SmoothStep<br>
      		SmootherStep<br>*</td>
    </tr> 
  </tbody>
</table>


##### .SpringCustom(velocity, frequency, damping)

The **SpringCustom** easing is an option apply a damping system as the easing for an animation. You have the option to provide the frequency (i.e bounciness), the damping ratio, and an initial velocity in the case you are using a pan gesture recognizer,

There are three ranges of values for the configuration of a spring
 
*  0 and 0.99, under-damped, the spring will bounce further
*  1.0, critically-damped, the spring should not bounce and slow into place
*  1.0 +, over damped, the spring will bounce, but not drastically 


##### .SpringDecay(velocity)

The **SpringDecay** option will slow an animation down easily into place with a preconfigured setting slightly overdamped preconfigured values for the spring configuration. Just like the SpringCustom configuration, it allows allows you to set the velocity in the case you are using a pan gesture recognizer.
