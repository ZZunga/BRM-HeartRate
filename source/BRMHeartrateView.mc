import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

class BRMHeartrateView extends WatchUi.DataField {

    hidden var currentHeartRate as Number or Null;		// 현재 심박
    hidden var averageHeartRate as Number or Null;		// 평균 심박
    
	hidden var currentHeartZone as Number or Null;		// 현재심박존(0~5)
    hidden var HZ_decimal as Float or Null;				// 심박존 %
    hidden var hrzArray = [0, 0, 0, 0, 0, 0] as Array<Number>;
    
	hidden var loc as Array<Number> or Null;
	hidden var fnt as Array<Graphics.FontDefinition> or Null;
	
	var width as Number or Null;
	var fontHeight as Number or Null;
	var HRlocX = 0 as Number;
	var normalizeOn = false as Boolean;

    enum {
        THEME_NONE,
        THEME_RED,
        THEME_RED_INVERT,
        INDICATE_HIGH,
        INDICATE_LOW,
        INDICATE_NORMAL
    }

    enum {
        MODE_AVERAGE,
        MODE_PERSONAL
    }

    function initialize() {
        DataField.initialize();
        currentHeartRate = 0;
        averageHeartRate = 0;
        currentHeartZone = 0;
        HZ_decimal = 0.0;
    }

    function onLayout(dc as Dc) as Void {
    	width = dc.getWidth();
    	fontHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
		getLoc();
    	var BigFont = Application.Properties.getValue("fontSize") == 1;
		if (BigFont) {
			HRlocX = dc.getTextWidthInPixels("Z0", fnt[1]) * 0.5;
		} else {
			HRlocX = dc.getTextWidthInPixels("Z0", fnt[2]) * 0.5;
		}		
	    View.setLayout(Rez.Layouts.MainLayout(dc));
    	width = dc.getWidth();
    }

	function getLoc() as Void {

		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_TINY, Graphics.FONT_NUMBER_MILD];

        switch (width) {
        	case 140: //Edge 1030, 1030 plus
        		if ( fontHeight != 48 ) {
	        		loc = [140, 2, 100,38, 78,38, 136,25, 138,17, 104,56, 82,56, 6, 14]; 
   	    		} else {
	        		loc = [140, 2, 100,25, 82,37, 133,30, 135,20, 102,58, 86,58, 6, 14];  
					fnt = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL];
				}
        		break;
        	case 282: //Edge 1030, 1030 plus
        		if ( fontHeight != 48 ) {
					loc = [140, 2, 100,38, 240,38, 105,56, 245,56, 6,33, 141,48, 6, 14];  
   	    		} else {
    	    		loc = [140, 2, 115,25, 245,25, 118,58, 248,58, 6,33, 141,45, 6, 14];
					fnt = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL];
				}
        		break;
        	case 119: //Edge 1000, Edge Explorer, Edge Explorer2
        		if ( fontHeight != 48 ) {
        			loc = [119, 2, 85,33, 68,33, 112,25, 115,18, 88,50, 72,50, 5, 12];
   	    		} else {
        			loc = [119, 2, 80,27, 72,27, 114,24, 118,18, 84,51, 74,51, 5, 12];
				}
        		break;
        	case 240: //Edge 1000, Edge Explorer, Edge Explorer2
        		if ( fontHeight != 48 ) {
        			loc = [119, 2, 85,32, 204,32, 89,49, 210,49, 5,28, 119,41, 5, 12];  
   	    		} else {
        			loc = [119, 2, 85,27, 205,27, 89,51, 210,51, 5,30, 118,43, 5, 12];
				}
        		break;
        	case 114: //Edge 130
        	case 115: //Edge 130 plus
        		loc = [115, 1, 65,23, 65,23, 110,24, 110,22, 67,45, 67,45, 4, 10];
				fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_SMALL, Graphics.FONT_TINY];
        		break;
        	case 230: //Edge 130 plus
        		loc = [115, 1, 65,23, 180,23, 67,45, 182,45, 0,26, 114,42, 4, 10];
				fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_SMALL, Graphics.FONT_TINY];
        		break;
        	case 99: //Edge 520, 520 plus
        		loc = [99, 0, 65,16, 65,16, 92,13, 92,13, 68,30, 68,30, 3, 8];
        		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_MEDIUM, Graphics.FONT_MEDIUM, Graphics.FONT_TINY];
        		break;
        	case 200: //Edge 520, 520 plus
        		loc = [99, 0, 67,16, 169,16, 70,30, 171,30, 3,14, 100,24, 3, 8];  
        		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_MEDIUM, Graphics.FONT_MEDIUM, Graphics.FONT_TINY];
        		break;
        	case 122: //Edge 530, 830
        		loc = [122, 1, 87,21, 68,21, 119,17, 120,10, 91,38, 71,38, 4, 9];  
        		break;
        	case 246: //Edge 530, 830
        		loc = [122, 1, 84,21, 208,21, 88,38, 212,38, 3,18, 122,31, 4, 9];
        		break;
        	default:
        		loc = [140, 2, 100,38, 78,38, 136,25, 138,17, 104,56, 82,56, 5, 14]; 
        }
	}
	
    function compute(info as Activity.Info) as Void {
    	if (info has :timerState && info.timerState == 0) {
			averageHeartRate = 0;
    		hrzArray = [0,0,0,0,0,0] as Array<Number>;
    	}
    	
     	if (info has :currentHeartRate && info.currentHeartRate != null) {
            currentHeartRate = info.currentHeartRate;
        } else {
           	currentHeartRate = 0;
        }

		var averagemode = Application.Properties.getValue("averageMode");
    	if (averagemode == 0) {
	    	if (info has :averageHeartRate && info.averageHeartRate != null) {
        	    averageHeartRate = info.averageHeartRate;
            } else {
            	averageHeartRate = 0;
    	    }
        } else {
	    	if (info has :maxHeartRate && info.maxHeartRate != null) {
        	    averageHeartRate = info.maxHeartRate;
            } else {
            	averageHeartRate = 0;
	        }
        }

        if (currentHeartRate != 0) {
        	computeHeartZone(currentHeartRate);
        } else {
        	currentHeartZone = 0;
        	return;
        }

/*		System.println(
			currentHeartRate + "/" +
			averageHeartRate + "/" +
			normalizeOn + " : " +
			hrzArray[0] + ", " +
			hrzArray[1] + ", " +
			hrzArray[2] + ", " +
			hrzArray[3] + ", " +
			hrzArray[4] + ", " +
			hrzArray[5] );
*/
        var HEARTZONEHISTORY = Application.Properties.getValue("HeartZoneHistory") as Boolean;
        if (info has :timerState && HEARTZONEHISTORY) {
			if (currentHeartZone > 0) {
        		hrzArray[currentHeartZone]++;
        		if ( hrzArray[currentHeartZone] > loc[15] ) {
        			normalizeOn = true;
        		}
        	}
        }
    }  
    
	function clearDC(dc as Dc) as Void {
		var backgroundColor = getBackgroundColor();
		var txtColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;

        dc.setColor(txtColor, backgroundColor);
        dc.clear();
	}

    function onUpdate(dc as Dc) as Void {
		clearDC(dc);
		width = dc.getWidth();
        var fullWidth = width > loc[0];
		var bgColor = getBackgroundColor();
        var colors = {
            :background => -1,
            :color => null,
            :hrt_color => null,
            :indication => INDICATE_NORMAL
        };

        var theme = Application.Properties.getValue("theme");
        var defaultColor, fastColor, slowColor;
        var backgroundColor = getBackgroundColor();
        var backgroundIsBlack = backgroundColor == Graphics.COLOR_BLACK;
        defaultColor = backgroundIsBlack ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
        
        var LightFontColor = [
			Graphics.COLOR_RED,
			Graphics.COLOR_ORANGE,
			Graphics.COLOR_YELLOW,
			Graphics.COLOR_GREEN,
			Graphics.COLOR_BLUE,
			Graphics.COLOR_PURPLE,
			Graphics.COLOR_PINK,
			Graphics.COLOR_LT_GRAY
		];
		var DarkFontColor = [
			Graphics.COLOR_DK_RED,
			Graphics.COLOR_ORANGE,
			Graphics.COLOR_YELLOW,
			Graphics.COLOR_DK_GREEN,
			Graphics.COLOR_DK_BLUE,
			Graphics.COLOR_PURPLE,
			Graphics.COLOR_PINK,
			Graphics.COLOR_DK_GRAY
		];

	   	var fastColorValue = Application.Properties.getValue("colorHigh");
	   	var slowColorValue = Application.Properties.getValue("colorLow");
		if (backgroundIsBlack) {
			fastColor = LightFontColor[fastColorValue];
			slowColor = LightFontColor[slowColorValue];
		} else {
			fastColor = DarkFontColor[fastColorValue];
			slowColor = DarkFontColor[slowColorValue];
		}
		LightFontColor = null;
		DarkFontColor = null;

        if (currentHeartRate != null) {
            var variations = getVariations();
            switch(theme) {
			case THEME_RED:
	            if (currentHeartRate > variations[:max]) {
    	        	colors[:hrt_color] = fastColor;
        	    	colors[:color] = defaultColor;
            		colors[:indication] = INDICATE_HIGH;
	            } else if (currentHeartRate < variations[:min]) {
    	        	colors[:hrt_color] = slowColor;
        	    	colors[:color] = defaultColor;
            		colors[:indication] = INDICATE_LOW;
	            } else {
    	        	colors[:hrt_color] = defaultColor;
        	    	colors[:color] = defaultColor;
            	}
       	    	break;
			case THEME_RED_INVERT:
	   		    if (currentHeartRate > variations[:max]) {
					colors[:background] = Graphics.COLOR_DK_RED;
					colors[:hrt_color] = Graphics.COLOR_WHITE;
					colors[:color] = Graphics.COLOR_WHITE;
					colors[:indication] = INDICATE_HIGH;
        	   	} else if (currentHeartRate < variations[:min]) {
					colors[:background] = Graphics.COLOR_DK_GREEN;
					colors[:hrt_color] = Graphics.COLOR_WHITE;
					colors[:color] = Graphics.COLOR_WHITE;
					colors[:indication] = INDICATE_LOW;
    	    	} else {
					colors[:hrt_color] = defaultColor;
					colors[:color] = defaultColor;
	       	    }
       	    	break;
       	    default:
				colors[:hrt_color] = defaultColor;
				colors[:color] = defaultColor;
			}       	    
        } else {
        	colors[:hrt_color] = defaultColor;
        	colors[:color] = defaultColor;
		}
		
        dc.setColor(colors[:color], colors[:background]);
        dc.clear();

   		drawHeartZones(dc, colors);
		// Full 화면모드에서 화살포 그리기
        if (!fullWidth) { return; }
        drawArrows(dc, colors);
    }

    function getComparableHeartRate() as Number {
        var mode = Application.Properties.getValue("heartrateMode") as Number;

        if (mode == MODE_PERSONAL) {
            return Application.Properties.getValue("personalHeartrate") as Number;
        }
        var avgHeart = averageHeartRate as Number;
        if ( avgHeart == null ) {
        	return 0;
        } else {
        	return avgHeart;
        }
    }

    function getVariations() as Dictionary {
        var threshold = Application.Properties.getValue("threshold").toFloat();
        var compareable = getComparableHeartRate();
        var control = compareable * (threshold/100.0);

        return {
            :min => compareable - control,
            :max => compareable + control
        };
    }

	// Full 화면 모드에서 화살표 그리기 함수
    function drawArrows(dc as Dc, colors as Dictionary) {
        var center = loc[12];
        var vcenter = loc[13];

        // up arrow, 13x7
        dc.setColor(colors[:indication] == INDICATE_HIGH ? colors[:hrt_color] : Graphics.COLOR_LT_GRAY, -1);
        if (loc[0]==115) {
        	if (colors[:indication] == INDICATE_HIGH) {
	        	dc.setColor(Graphics.COLOR_BLACK, -1);
    	    	dc.fillPolygon([[center - 6, vcenter + 6], [center, vcenter], [center + 6, vcenter + 6]]);
        	} else {
	        	dc.setColor(Graphics.COLOR_BLACK, -1);
    	    	dc.drawLine(center - 6, vcenter + 6, center, vcenter);
        		dc.drawLine(center - 6, vcenter + 6, center + 6, vcenter + 6);
        		dc.drawLine(center, vcenter, center + 6, vcenter + 6);
        	}
		} else {        	
			dc.fillPolygon([[center - 6, vcenter + 6], [center, vcenter], [center + 6, vcenter + 6]]);
		}

        // down arrow, 13x7
        dc.setColor(colors[:indication] == INDICATE_LOW ? colors[:hrt_color] : Graphics.COLOR_LT_GRAY, -1);
        if (loc[0]==115) {
        	if ( colors[:indication] == INDICATE_LOW) {
	        	dc.setColor(Graphics.COLOR_BLACK, -1);
		        dc.fillPolygon([[center - 6, vcenter + 10], [center, vcenter + 16], [center + 6, vcenter + 10]]);
	    	} else if (loc[0] == 115) {
        		dc.setColor(Graphics.COLOR_BLACK, -1);
	        	dc.drawLine(center - 6, vcenter + 10, center, vcenter + 16);
    	    	dc.drawLine(center - 6, vcenter + 10, center + 6, vcenter + 10);
        		dc.drawLine(center, vcenter + 16, center + 6, vcenter + 10);
        	}
		} else {
	        dc.fillPolygon([[center - 6, vcenter + 10], [center, vcenter + 16], [center + 6, vcenter + 10]]);
		}	    
    }
    
    function computeHeartZone(hr as Number) as Void {
		// 심박존
		// Zone 0 : under Zone 1
		// Zone 1 : recovery, 50~60% of HR max
		// Zone 2 : endurance 60~70% of HR max
		// Zone 3 : aerobic 70~80% of HR max
		// Zone 4 : lactate 80~90% of HR max
		// Zone 5 : VO2 90~100% of HR max

		var heartZoneThreshold = [0,0,0,0,0,0];
        var manualHeartZone = Application.Properties.getValue("manualHeartZone");
		var calcHeartZone = Application.Properties.getValue("calcHeartZone");
		if (manualHeartZone) {
			heartZoneThreshold[0] = Application.Properties.getValue("Zone1minValue");
			heartZoneThreshold[1] = Application.Properties.getValue("Zone1maxValue");
			heartZoneThreshold[2] = Application.Properties.getValue("Zone2maxValue");
			heartZoneThreshold[3] = Application.Properties.getValue("Zone3maxValue");
			heartZoneThreshold[4] = Application.Properties.getValue("Zone4maxValue");
			heartZoneThreshold[5] = Application.Properties.getValue("Zone5maxValue");
		} else if (calcHeartZone) {
			var maxHR = Application.Properties.getValue("maxHeartRate").toFloat();
			if (maxHR == null || maxHR == 0) { maxHR = 180; }
			var calcTypeHZ = Application.Properties.getValue("calcTypeHZ");
			switch(calcTypeHZ) {
			case 1: // Coggan
				heartZoneThreshold[0] = Math.floor(maxHR * 0.65);
				heartZoneThreshold[1] = Math.floor(maxHR * 0.82);
				heartZoneThreshold[2] = Math.floor(maxHR * 0.89);
				heartZoneThreshold[3] = Math.floor(maxHR * 0.94);
				heartZoneThreshold[4] = Math.floor(maxHR * 1.00);
				heartZoneThreshold[5] = Math.floor(maxHR * 1.06);
				break;
			case 2: // Friel
				heartZoneThreshold[0] = Math.floor(maxHR * 0.50);
				heartZoneThreshold[1] = Math.floor(maxHR * 0.69);
				heartZoneThreshold[2] = Math.floor(maxHR * 0.84);
				heartZoneThreshold[3] = Math.floor(maxHR * 0.95);
				heartZoneThreshold[4] = Math.floor(maxHR * 1.06);
				heartZoneThreshold[5] = Math.floor(maxHR * 1.1);
				break;
			case 3: // USA
				heartZoneThreshold[0] = Math.floor(maxHR * 0.50);
				heartZoneThreshold[1] = Math.floor(maxHR * 0.66);
				heartZoneThreshold[2] = Math.floor(maxHR * 0.73);
				heartZoneThreshold[3] = Math.floor(maxHR * 0.84);
				heartZoneThreshold[4] = Math.floor(maxHR * 0.91);
				heartZoneThreshold[5] = Math.floor(maxHR * 1.1);
				break;
			case 4: // British
				heartZoneThreshold[0] = Math.floor(maxHR * 0.50);
				heartZoneThreshold[1] = Math.floor(maxHR * 0.65);
				heartZoneThreshold[2] = Math.floor(maxHR * 0.75);
				heartZoneThreshold[3] = Math.floor(maxHR * 0.82);
				heartZoneThreshold[4] = Math.floor(maxHR * 0.89);
				heartZoneThreshold[5] = Math.floor(maxHR * 0.94);
				break;
			case 5: // Strava
				heartZoneThreshold[0] = Math.floor(maxHR * 0.50);
				heartZoneThreshold[1] = Math.floor(maxHR * 0.59);
				heartZoneThreshold[2] = Math.floor(maxHR * 0.78);
				heartZoneThreshold[3] = Math.floor(maxHR * 0.875);
				heartZoneThreshold[4] = Math.floor(maxHR * 0.97);
				heartZoneThreshold[5] = Math.floor(maxHR * 1.1);
				break;
			case 6: // Garmin
				heartZoneThreshold[0] = Math.floor(maxHR * 0.5);
				heartZoneThreshold[1] = Math.floor(maxHR * 0.6);
				heartZoneThreshold[2] = Math.floor(maxHR * 0.7);
				heartZoneThreshold[3] = Math.floor(maxHR * 0.8);
				heartZoneThreshold[4] = Math.floor(maxHR * 0.9);
				heartZoneThreshold[5] = Math.floor(maxHR * 1.0);
				break;
			default:
				heartZoneThreshold[0] = Math.floor(maxHR * 0.65);
				heartZoneThreshold[1] = Math.floor(maxHR * 0.80);
				heartZoneThreshold[2] = Math.floor(maxHR * 0.89);
				heartZoneThreshold[3] = Math.floor(maxHR * 0.95);
				heartZoneThreshold[4] = Math.floor(maxHR * 1.0);
				heartZoneThreshold[5] = Math.floor(maxHR * 1.07);
			}
		} else {
			heartZoneThreshold = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_BIKING);
		}
		if (heartZoneThreshold[0] == null || heartZoneThreshold[0] == 0) {
			heartZoneThreshold = [117,114,160,171,189,192]; 
		}

		if (currentHeartRate !=null && currentHeartRate !=0) {
			for (var hrt_i=1;hrt_i<6;hrt_i++) {
				if (hrt_i == 1 && hr < heartZoneThreshold[0]) {
					currentHeartZone = 0;
					HZ_decimal = 0.0;
					return;
				} else if (hr > heartZoneThreshold[0] && hr <= heartZoneThreshold[hrt_i]) {
					if (hr > heartZoneThreshold[hrt_i-1] && hr <= heartZoneThreshold[hrt_i]) {
						currentHeartZone = hrt_i;
						var minZone = heartZoneThreshold[hrt_i-1].toFloat();
						var maxZone = heartZoneThreshold[hrt_i].toFloat();
						HZ_decimal = (hr.toFloat() - minZone) / (maxZone - minZone);
					} else if (hr > heartZoneThreshold[5]) { 
						currentHeartZone = 5; 
						HZ_decimal = 1.0;
						return; 
					} 
				} 
			}
		}
	}
	
	function drawHeartZones(dc as Dc, colors as Dictionary) {
		width = dc.getWidth();
	    var fullWidth = width > loc[0];
	    var bgColor = getBackgroundColor();
	    var defaultColor = bgColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
		var zone_w = (dc.getWidth()-loc[14]*2.0) / 5.0;
		var zone_h = loc[14];
		var x_left = loc[14];
		var y_bottom = dc.getHeight();
        var center;
        var vcenter = y_bottom - zone_h;
    	var heartZoneColor = [
			Graphics.COLOR_DK_GRAY,
	        Graphics.COLOR_LT_GRAY,
    	    Graphics.COLOR_BLUE,
        	Graphics.COLOR_DK_GREEN,
        	Graphics.COLOR_YELLOW,
    	    Graphics.COLOR_RED
		];
		if (bgColor == Graphics.COLOR_BLACK) {
			heartZoneColor = [
				Graphics.COLOR_LT_GRAY,
		        Graphics.COLOR_LT_GRAY,
    		    Graphics.COLOR_BLUE,
        		Graphics.COLOR_GREEN,
        		Graphics.COLOR_YELLOW,
    		    Graphics.COLOR_RED
			];
		}
		if (loc[0]==115) {
			heartZoneColor = [
				Graphics.COLOR_DK_GRAY,
		        Graphics.COLOR_DK_GRAY,
		   	    Graphics.COLOR_DK_BLUE,
		       	Graphics.COLOR_DK_GREEN,
		       	Graphics.COLOR_ORANGE,
		   	    Graphics.COLOR_DK_RED
			];
		}

        var HEARTZONEBAR = Application.Properties.getValue("HeartZoneBar");
		if (HEARTZONEBAR) {
			dc.setColor(heartZoneColor[1], -1);
			dc.fillRectangle(x_left, y_bottom - zone_h, zone_w - 1, zone_h);
			dc.setColor(heartZoneColor[2], -1);
			dc.fillRectangle(x_left + zone_w, y_bottom - zone_h, zone_w - 1, zone_h);
			dc.setColor(heartZoneColor[3], -1);
			dc.fillRectangle(x_left + zone_w * 2.0, y_bottom - zone_h, zone_w - 1, zone_h);
			dc.setColor(heartZoneColor[4], -1);
			dc.fillRectangle(x_left + zone_w * 3.0, y_bottom - zone_h, zone_w - 1, zone_h);
			dc.setColor(heartZoneColor[5], -1);
			dc.fillRectangle(x_left + zone_w * 4.0, y_bottom - zone_h, zone_w - 1, zone_h);
		}
		
        var HEARTZONEHISTORY = Application.Properties.getValue("HeartZoneHistory");
		if (HEARTZONEHISTORY) {
		    var hrzNArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0] as Array<Float>;
			hrzNArray = normalizeArray();
			for (var inc_j=1; inc_j<6; inc_j++) {
       	 		dc.setColor(heartZoneColor[inc_j], -1);
				var x = x_left + zone_w * (inc_j-1);
				var y; 
	        	for (var inc_k=0; inc_k < hrzNArray[inc_j]; inc_k++) {
        		 	y = vcenter - (inc_k + 1) * 4;
        			dc.drawLine (x, y, x + zone_w - 1, y);  
    	    	}
	        } 
		}

		var hrv, avv, mtv, lbv, hzv, ttv;
		var metric = loadResource(Rez.Strings.metric);
		var avgHR;
		if (averageHeartRate != null) { 
			avgHR = averageHeartRate.format("%d");
		} else { avgHR = ""; }
        var hrtMode = Application.Properties.getValue("heartrateMode");
		var label = hrtMode == MODE_AVERAGE ? loadResource(Rez.Strings.labelAvg) : loadResource(Rez.Strings.labelPersonal);
		var smallFont = (Application.Properties.getValue("fontSize") == 0);
		var title1 = loadResource(Rez.Strings.title);
		var title2;
		var averagemode = Application.Properties.getValue("averageMode");
		switch(averagemode) {
			case 0:		title2 = loadResource(Rez.Strings.modeAvg);		break;
			case 1:		title2 = loadResource(Rez.Strings.modeMax);		break;
			default:	title2 = "Avg";
		}
		var title = title1 + "/" + title2;
		
        if (fullWidth) {
			hrv = [loc[2], loc[3], fnt[0]];
			avv = [loc[4], loc[5], fnt[0], avgHR];
			mtv = [loc[6], loc[7], loc[8], loc[9], fnt[3], metric];
			lbv = [loc[8], loc[11], fnt[3], label];
			hzv = [loc[14], loc[1], smallFont ? fnt[2] : fnt[1]];
			ttv = [width/2, loc[1], fnt[3], title];
        } else {
			if (!smallFont) {
				hrv = [loc[4], loc[5], fnt[0]];
				if (width==140&&fontHeight==48) {
					hrv[2] = Graphics.FONT_NUMBER_MILD;
				}
				avv = [loc[8], loc[9], fnt[1], avgHR];
				mtv = [loc[12], loc[13], 0,0, fnt[3], metric];
				lbv = [loc[8], loc[11], fnt[3], label];
				hzv = [loc[14], loc[1], fnt[1]];
				ttv = [width * 0.5 + HRlocX, loc[1], fnt[3], title];
			} else {
				hrv = [loc[2], loc[3], fnt[0]];
				avv = [loc[6], loc[7], fnt[2], avgHR];
				mtv = [loc[10], loc[11], 0,0, fnt[3], metric];
				lbv = [loc[8], loc[11], fnt[3], label];
				hzv = [loc[14], loc[1], fnt[2]];
				ttv = [width * 0.5 + HRlocX, loc[1], fnt[3], title];
			}
		}
		if (currentHeartRate !=null && currentHeartRate >=0) {
			dc.setColor(colors[:hrt_color], -1);
    	   	dc.drawText(hrv[0], hrv[1], hrv[2], currentHeartRate.format("%d"), Graphics.TEXT_JUSTIFY_RIGHT);
		}
		hrv = null;
		
		if (bgColor == Graphics.COLOR_BLACK) {
			heartZoneColor = [
				Graphics.COLOR_LT_GRAY,
		        Graphics.COLOR_LT_GRAY,
    		    Graphics.COLOR_BLUE,
        		Graphics.COLOR_GREEN,
        		Graphics.COLOR_YELLOW,
    		    Graphics.COLOR_RED
			];
		} else {
			heartZoneColor = [
				Graphics.COLOR_DK_GRAY,
		        Graphics.COLOR_DK_GRAY,
		   	    Graphics.COLOR_DK_BLUE,
		       	Graphics.COLOR_DK_GREEN,
		       	Graphics.COLOR_ORANGE,
		   	    Graphics.COLOR_DK_RED
			];
		}
		var hzColor = heartZoneColor[currentHeartZone];

		dc.setColor(hzColor, colors[:background]);
       	dc.drawText(hzv[0], hzv[1], hzv[2], "Z" + currentHeartZone.format("%d"), Graphics.TEXT_JUSTIFY_LEFT);
		heartZoneColor = null;

		dc.setColor(defaultColor, colors[:background]);
		dc.drawText(avv[0], avv[1], avv[2], avv[3], Graphics.TEXT_JUSTIFY_RIGHT);
		dc.drawText(mtv[0], mtv[1], mtv[4], mtv[5], Graphics.TEXT_JUSTIFY_LEFT);
		dc.drawText(ttv[0], ttv[1], ttv[2], ttv[3], Graphics.TEXT_JUSTIFY_CENTER);
		if (fullWidth) {
			dc.drawText(mtv[2], mtv[3], mtv[4], mtv[5], Graphics.TEXT_JUSTIFY_LEFT);
			dc.drawText(lbv[0], lbv[1], lbv[2], lbv[3], Graphics.TEXT_JUSTIFY_LEFT);
		}

		if(HEARTZONEBAR) {
	        var arrColor = bgColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
    	    var arrSize = loc[14];
        	if (currentHeartZone == 0) {
        		center = x_left;
	        } else if (currentHeartZone == 5 && HZ_decimal == 1) {
    	    	center = x_left + zone_w * 5;
        	} else {
        		center = x_left + zone_w * (currentHeartZone-1) + zone_w * HZ_decimal;
	        }
    	   if (loc[0] == 115) { 
        		arrColor = Graphics.COLOR_WHITE; 
        		dc.setColor(arrColor, -1);
	         	dc.fillPolygon([[center - arrSize, vcenter + arrSize], [center, vcenter], [center + arrSize, vcenter + arrSize]]);
    	    } else if (loc[0] == 99 || loc[0] == 122) { 
        		dc.setColor(arrColor, -1);
        		dc.fillPolygon([[center - arrSize, vcenter + arrSize], [center, vcenter], [center + arrSize, vcenter + arrSize]]);
	        } else {
    	    	dc.setColor(arrColor, -1);
        		dc.fillPolygon([[center - arrSize, vcenter - arrSize], [center, vcenter], [center + arrSize, vcenter - arrSize]]);
        	}
        }
	}
	
	function normalizeArray() as Array<Float> {
		var sumArray = 0.0 as Float;
		var maxAA = 0.0 as Float;
		var hrzNArray = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0] as Array<Float>;
		for (var inc_j = 0; inc_j < 6 ; inc_j++) {
			sumArray += hrzArray[inc_j];
			hrzNArray[inc_j] = hrzArray[inc_j].toFloat();
			if (hrzArray[inc_j]>maxAA) { maxAA = hrzArray[inc_j].toFloat(); }
		}

		if (maxAA > 0 && normalizeOn) {
			for (var inc_j = 0; inc_j < 6; inc_j++) {
				hrzNArray[inc_j] = hrzArray[inc_j] / maxAA * loc[15];
			} 
		}
		return hrzNArray;
	}
}