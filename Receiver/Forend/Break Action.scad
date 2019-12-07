include <../../Meta/Animation.scad>;

use <../../Meta/Manifold.scad>;
use <../../Meta/Units.scad>;
use <../../Meta/Debug.scad>;
use <../../Meta/Resolution.scad>;
use <../../Meta/RenderIf.scad>;

use <../../Shapes/Chamfer.scad>;
use <../../Shapes/Bearing Surface.scad>;
use <../../Shapes/Teardrop.scad>;
use <../../Shapes/TeardropTorus.scad>;
use <../../Shapes/Semicircle.scad>;
use <../../Shapes/ZigZag.scad>;

use <../../Shapes/Components/Cylinder Redux.scad>;
use <../../Shapes/Components/Pivot.scad>;
use <../../Shapes/Components/Pump Grip.scad>;

use <../../Vitamins/Nuts And Bolts.scad>;
use <../../Vitamins/Pipe.scad>;
use <../../Vitamins/Rod.scad>;

use <../../Ammo/Shell Slug.scad>;

use <../Lugs.scad>;
use <../Frame.scad>;
use <../Receiver.scad>;
use <../Compact Linear Hammer.scad>;
use <../Recoil Plate.scad>;
use <../Action Rod.scad>;

use <Bipod.scad>;


/* [What to Render] */

// Assembly is not for printing.
_RENDER = "Assembly"; // ["Assembly", "BarrelPivotCollar", "BarrelLatchCollar", "RecoilPlateHousing", "Forend", "Foregrip", "Extractor", "Latch", "LatchFront"]

// Cut assembly view in half
_DEBUG_ASSEMBLY = false;

/* [Screws] */
GP_BOLT = "#8-32"; // ["M4", "#8-32"]
GP_BOLT_CLEARANCE = 0.015;

BARREL_SET_SCREW = "#8-32"; // ["M4", "#8-32"]
BARREL_SET_SCREW_CLEARANCE = -0.05;

//CHAMBER_OUTSIDE_DIAMETER = 1;
//CHAMBER_INSIDE_DIAMETER = 0.813;


$fs = UnitsFs()*0.5;

// Settings: Vitamins
function BarrelPipe() = Spec_PipeThreeQuarterInch();
function BarrelSleevePipe() = Spec_PipeOneInch();
function ChamberBolt() = Spec_BoltM3();

function BarrelSetScrew() = BoltSpec(BARREL_SET_SCREW);
assert(BarrelSetScrew(), "BarrelSetScrew() is undefined. Unknown BARREL_SET_SCERW?");

function GPBolt() = BoltSpec(GP_BOLT);
assert(GPBolt(), "GPBolt() is undefined. Unknown GP_BOLT?");

// Settings: Lengths
function BarrelLength() = 18;
function BarrelSleeveLength() = 4;
function WallBarrel() = 0.1875;
function WallPivot() = (7/16);

// Settings: Positions
function ActionRodZ() = FrameBoltZ()-WallFrameUpperBolt()-(ActionRodWidth()/2);

// Shorthand: Measurements
function PivotWidth() = 1.125;
function PivotDiameter() = .25;
function PivotRadius() = PivotDiameter()/2;

function BarrelRadius(clearance=undef)
    = PipeOuterRadius(BarrelPipe(), clearance);

function BarrelDiameter(clearance=undef)
    = PipeOuterDiameter(BarrelPipe(), clearance);

function BarrelSleeveRadius(clearance=undef)
    = PipeOuterRadius(BarrelSleevePipe(), clearance);

function BarrelSleeveDiameter(clearance=undef)
    = PipeOuterDiameter(BarrelSleevePipe(), clearance);


// Calculated: Lengths
function LatchCollarLength() = 3;
function FrameForendExtension() = 4.5;
function ForendFrontLength() = 1.5;
function ChargerTravel() = 1.125;


function ForegripOffsetX() = 0.25;
function ForegripLength() = 4.625;

// Calculated: Positions
function FiringPinMinX() = -1.5-2;
function BarrelOffsetZ() = 0; // -0.11 for .22LR rimfire
function ForendMaxX() = FrameUpperBoltExtension()+RecoilPlateRearX();
function ForendMinX() = ForendMaxX()-ForendFrontLength();
function PivotAngle() = -30;
function PivotX() = 5.5;
function PivotZ() = FrameBoltZ()
                  + (FrameUpperBoltRadius()+PivotRadius());


function ExtractorAngles() = [90,-90];
function ExtractorWidth() = (1/4);
function ExtractorLength() = 1;
function ExtractorWall() = 0.1875;
function ExtractorTravel() = 0.5;
function ExtractorGuideLength() = 4;
function ExtractorGuideZ() = -BarrelSleeveRadius()
                             -WallBarrel()
                             -(ActionRodWidth()/2);

function LatchSpringLength() = 2.125;
function LatchSpringDiameter() = 0.625;
function LatchSpringRadius() = LatchSpringDiameter()/2;
function LatchSpringFloor() = 0.25;
function LatchWall() = 0.1875;

function LatchRodDiameter() = ActionRodWidth();
function LatchRodRadius() = LatchRodDiameter()/2;
function LatchRodLength() = ReceiverFrontLength()
                          + PivotX()
                          + PivotRadius() + WallPivot()
                          + 0.625;
function LatchRodZ() = -BarrelSleeveRadius()
                       -WallBarrel()
                       -LatchSpringRadius();
function LatchSupportWidth() = (LatchSpringRadius()+LatchWall())*2;
function LatchFlatZ() = -(BarrelRadius()+0.5);
function LatchFlatWidth() = 1.5;

module BreakActionPivot(factor=0) {
  Pivot2(xyz=[PivotX(),0,PivotZ()],
         angle=[0,PivotAngle(),0],
         factor=factor)
  children();
}
module ExtractorBit(cutter=false, clearance=0.003) {
  clear = cutter?clearance:0;
  clear2 = clear*2;

  color("DimGrey") RenderIf(!cutter)
  translate([ExtractorWidth()/8,0,-(11/32)])
  rotate([0,155,0])
  difference() {
    rotate(30)
    cylinder(r=((ExtractorWidth()/2)/cos(30))+clear,
             h=ExtractorLength(), $fn=6);

    if (!cutter)
    for (M = [0,1]) mirror([M,0,0])
    hull() for (Z = [0,ExtractorWidth()/2])
    translate([ExtractorWidth()*0.7,0,Z])
    scale([1,1,1.75])
    rotate([90,0,0])
    cylinder(r=ExtractorWidth()/2,
             h=ExtractorWidth()*(1+cos(30)),
             center=true);
  }
}

module ExtractorScrew(cutter=false, clearance=0.008) {
  clear = cutter ? clearance : 0;
  clear2 = clear*2;

  // Secure the extractor to the guide rod
  color("Silver")
  translate([0.5+0.5, 0,ExtractorGuideZ()+(ActionRodWidth()/2)])
  mirror([0,0,1])
  Bolt(bolt=GPBolt(),
       length=0.5+ManifoldGap(), clearance=clear,
       head="flat", capHeightExtra=(cutter?1:0));

  // Actuator pin for the guiderod
  color("Silver")
  translate([3.125+0.625, 0,ExtractorGuideZ()+(ActionRodWidth()/2)])
  Bolt(bolt=GPBolt(),
       length=ActionRodWidth()+ManifoldGap(),
       head="socket", capHeightExtra=(cutter?1:0),
        capOrientation=true);
}

module ExtractorGuideRod(cutter=false, clearance=0.01) {
  clear = cutter ? clearance : 0;
  clear2 = clear*2;

  // Rod
  color("Silver")
  translate([0.625, 0,ExtractorGuideZ()])
  translate([0,-LatchRodRadius()-clear, -(ActionRodWidth()/2)-clear])
  cube([ExtractorGuideLength(),
        (LatchRodRadius()+clear)*2,
        (LatchRodRadius()+clear)*2]);
}

module LatchRod(cutter=false, clearance=0.008) {
  clear = cutter ? clearance : 0;
  clear2 = clear*2;

  // Rod
  color("Silver")
  for (M = [0,1]) mirror([0,M,0])
  translate([RecoilPlateRearX(), -(LatchRodRadius()+clear), LatchRodZ()-(LatchRodRadius()+clear)])
  cube([LatchRodLength()+(cutter?LatchSpringLength():0),
        (LatchRodRadius()+clear)*2,
        (LatchRodRadius()+clear)*2]);
}

module LatchSpring(cutter=false, clearance=0.015) {
  clear = cutter?clearance:0;

  color("Silver", 0.25)
  for (M = [0,1]) mirror([0,M,0])
  translate([LatchCollarLength()-LatchSpringFloor(), 0, LatchRodZ()])
  rotate([0,-90,0])
  cylinder(r=LatchSpringRadius()+clear,
           h=cutter?LatchCollarLength():LatchSpringLength());
}

module LatchScrews(debug=false, cutter=false, clearance=0.008) {
  clear = cutter?clearance:0;
  clear2 = clear*2;

  // Secure the latch block to the latch rod
  color("Gold")
  translate([0.3125,0,LatchRodZ()+(ActionRodWidth()/2)])
  rotate([180,0,0])
  Bolt(bolt=GPBolt(),
       length=0.5+ManifoldGap(), clearance=clear,
       head="flat", capHeightExtra=(cutter?1:0));

  // Actuator pin for the guiderod
  color("Gold")
  translate([LatchRodLength()-0.3125-ReceiverFrontLength(),
             0,
             LatchRodZ()])
  rotate([180,0,0])
  Bolt(bolt=GPBolt(),
       length=0.5+ManifoldGap(),
       head="flat", capHeightExtra=(cutter?1:0));
}


module BreakActionRecoilPlateHousing(debug=false, alpha=1) {
  color("MediumSlateBlue", alpha)
  DebugHalf(enabled=debug) render()
  difference() {
    ReceiverFront() {
      hull() {

        // Match the recoil plate
        translate([0,-2.25/2,LowerOffsetZ()])
        ChamferedCube([ReceiverFrontLength(),
                       2.25,
                       abs(LatchRodZ())], r=1/16);

        // Latch Rod Support
        translate([0,-0.5/2,LatchRodZ()-1])
        ChamferedCube([ReceiverFrontLength(),
                       0.5,
                       1], r=1/16);
      }
    }

    RecoilPlate(cutter=true);

    RecoilPlateFiringPinAssembly(cutter=true);

    translate([-ReceiverFrontLength(),0,ActionRodZ()])
    ActionRod(cutter=true);

    LatchRod(cutter=true);
  }
}

module BreakActionRecoilPlateHousing_print() {
  rotate([0,-90,0]) translate([-RecoilPlateRearX(),0,0])
  BreakActionRecoilPlateHousing();
}

module Barrel(barrel=BarrelPipe(), length=BarrelLength(),
              clearance=PipeClearanceSnug(),
              cutter=false, alpha=1, debug=false) {

  color("Silver") DebugHalf(enabled=!cutter&&debug)
  RenderIf(!cutter)
  translate([0,0,BarrelOffsetZ()])
  difference() {
    rotate([0,90,0])
    union() {
      Pipe(pipe=BarrelSleevePipe(),
           length=BarrelSleeveLength(),
           hollow=!cutter, clearance=(cutter?clearance:undef));

      Pipe(pipe=barrel, clearance=(cutter?clearance:undef),
           hollow=!cutter, length=length);
    }

    // Extractor notch
    if (!cutter)
    for (R = ExtractorAngles()) rotate([R,0,0])
    rotate([90,0,0])
    translate([0,-0.813*0.5,0])
    rotate(40)
    translate([ExtractorWidth()/4,0.813*0.5*0.1,-ExtractorWidth()/2])
    mirror([1,1,0])
    cube([BarrelDiameter(), BarrelRadius(), ExtractorWidth()]);
  }
}



module Extractor(cutter=false, clearance=0.01, alpha=1) {
  clear = cutter ? clearance : 0;
  clear2 = clear*2;

  color("Tan", alpha)
  RenderIf(!cutter)
  difference() {
    union() {

      // Long lower section
      translate([+clear,
                 -(0.625/2)-clear,
                 ExtractorGuideZ()+(ActionRodWidth()/2)+clear])
      mirror([0,0,1])
      ChamferedCube([1.375+clear,
                     0.625+clear2,
                     ActionRodWidth()+0.25+clear2], r=1/16);

      // Tall portion to hold the bit
      translate([clear,
                 -(0.625/2)-clear,
                 ExtractorGuideZ()-0.375])
      ChamferedCube([0.625+clear,
                     0.625+clear2,
                     (BarrelRadius()+ExtractorLength())],
                    r=1/16);
    }

    if (!cutter) {
      Barrel(cutter=true, clearance=PipeClearanceLoose());

      ExtractorBit(cutter=true);

      ExtractorScrew(cutter=true);

      translate([0,0,clearance])
      ExtractorGuideRod(cutter=true);
    }
  }
}

module Extractor_print() {
  translate([0,0,-ExtractorGuideZ()+0.625])
  Extractor();
}

module ExtractorAssembly(cutter=false) {
  for (R = ExtractorAngles()) rotate([R,0,0]) {
    ExtractorBit(cutter=cutter);
    ExtractorGuideRod(cutter=cutter);
    ExtractorScrew(cutter=cutter);
    Extractor(cutter=cutter);
  }
}
module BreakActionForend(debug=false, alpha=1) {

  // Forward plate
  color("MediumSlateBlue", alpha)
  DebugHalf(enabled=debug) render()
  difference() {
    union() {

      // Extractor pusher
      *translate([PivotX(),FrameBoltY(),-0.5])
      #ChamferedCube([0.51,0.25,FrameBoltZ()], r=1/16
      );

      // Pivot support
      hull() {

        translate([ForendMaxX(), 0, 0])
        mirror([1,0,0])
        FrameSupport(length=ForendFrontLength());

        translate([PivotX(), 0, PivotZ()])
        rotate([90,0,0])
        translate([0,0,-FrameBoltY()-FrameUpperBoltRadius()-WallFrameUpperBolt()])
        ChamferedCylinder(r1=0.5, r2=1/16,
                 h=(FrameBoltY()+FrameUpperBoltRadius()+WallFrameUpperBolt())*2,
                 $fn=Resolution(20,60));
      }
    }

    // Pivot slot
    translate([PivotX()-(PivotRadius()+WallPivot()),
                -PivotWidth()/2, 0])
    ChamferedCube([(PivotRadius()+WallPivot())*2,
                   PivotWidth(),
                   FrameBoltZ()+FrameUpperBoltDiameter()+(WallFrameUpperBolt()*2)],
                  r=1/16);

    // Pivot rod
    translate([PivotX(), 0, PivotZ()])
    rotate([90,0,0])
    cylinder(r=PivotRadius()+0.01, h=4, center=true);

    FrameBolts(cutter=true);

    ActionRod(cutter=true);
  }
}

module BreakActionForend_print() {
  rotate([0,-90,0])
  translate([-FrameUpperBoltExtension()+ForendFrontLength(),0,-FrameBoltZ()])
  BreakActionForend();
}


module LatchFlatTop(length=LatchCollarLength(),
                    cutter=false, clearance=0.015) {
  clear = cutter?clearance:0;
  clear2 = clear*2;
    translate([0, -(LatchFlatWidth()/2)-clear,
               LatchFlatZ()])
    ChamferedCube([length,
                   LatchFlatWidth()+clear2,
                   abs(LatchRodZ())],
                   r=1/16);
}

module LatchTabs(length=LatchCollarLength(), cutter=false, clearance=0.01) {
  clear = cutter?clearance:0;
  clear2 = clear*2;

  // Bottom Tabs
  translate([0, -(LatchSupportWidth()/2)-0.125-clear,
             LatchRodZ()
             -(LatchSpringRadius()+LatchWall())
             -0.125-clear])
  ChamferedCube([length,
                 LatchSupportWidth()+0.25+clear2,
                 0.25+clear2],
                 r=1/16);
}


module LatchSupport(length=LatchCollarLength(),
                    width=LatchSupportWidth(),
                    cutter=false, clearance=0.015,
                    debug=false, alpha=1) {
  clear = cutter?clearance:0;
  clear2 = clear*2;

  // Latch block
  translate([0, -(width/2)-clear,
             LatchRodZ()-(LatchSpringRadius()+LatchWall())])
  ChamferedCube([length,
                 width+clear2,
                 abs(LatchRodZ())],
                 r=1/16);
}


module Latch(debug=false, cutter=false, clearance=0.015, alpha=1) {
  clear = cutter?clearance:0;
  clear2 = clear*2;

  // Latch block
  color("Tomato", alpha)
  DebugHalf(enabled=debug) RenderIf(!cutter)
  difference() {
    union() {
      translate([(cutter?-0.25:0),
                 -(LatchSpringRadius()+clear),
                 LatchRodZ()+LatchSpringRadius()+clear])
      mirror([0,0,1])
      ChamferedCube([0.625+(cutter?LatchSpringLength()+0.25:0),
                     (LatchSpringRadius()+clear)*2,
                     LatchSpringRadius()+0.5-LatchRodRadius()+clear2],
                     r=1/16);
    }

    if (!cutter) {
      LatchScrews(cutter=true);

      LatchRod(cutter=true);
    }
  }
}
module Latch_print() {
  //rotate([0,-90,0])
  translate([0,0,-LatchRodZ()])
  Latch();
}

module LatchFront(debug=false, cutter=false, clearance=0.015, alpha=1) {
  clear = cutter?clearance:0;
  clear2 = clear*2;

  width=LatchFlatWidth();

  // Latch block
  color("Tomato", alpha)
  DebugHalf(enabled=debug) RenderIf(!cutter)
  difference() {
    union() {
      translate([LatchRodLength()-0.625-ReceiverFrontLength()+(cutter?0.51:0),
                 -(width/2)-clear,
                 LatchRodZ()+LatchRodRadius()-0.5-0.125])
      ChamferedCube([0.625+(cutter?LatchSpringLength()+0.25:0),
                     width+clear2,
                     0.5+0.125+clear2],
                     r=1/16);
    }

    if (!cutter) {
      LatchScrews(cutter=true);

      LatchRod(cutter=true);
    }
  }
}
module LatchFront_print() {
  translate([-LatchRodLength()+0.625+ReceiverFrontLength(),0,-LatchRodZ()+0.5-LatchRodRadius()])
  LatchFront();
}

module BarrelForegripCollar(length=0.75+0.0625) {

  X=3+ChargerTravel();

  color("Burlywood") render()
  difference() {
    union() {

      // Around the action rod
      translate([X,
                 -length/2,0])
      ChamferedCube([length, length, ActionRodZ()-0.125-0.01], r=1/16);

      // Around the barrel
      translate([X,
                 0,BarrelOffsetZ()])
      rotate([0,90,0])
      ChamferedCylinder(r1=BarrelSleeveRadius()+WallBarrel(), r2=1/16,
               h=length,
               $fn=40);

      // Latch support shape
      translate([X,0,0]) {
        LatchSupport(length=length);
        LatchTabs(length=length);
      }
    }

    LatchScrews(cutter=true);

    LatchRod(cutter=true);

    LatchSpring(cutter=true);

    translate([1,0,0])
    Barrel(cutter=true, clearance=PipeClearanceLoose());
  }
}
module BarrelLatchCollar(debug=false, alpha=1, cutter=false) {
  color("DarkSlateBlue", alpha)
  DebugHalf(enabled=!cutter&&debug) render()
  difference() {
    union() {

      // Around the barrel sleeve
      hull() {

        rotate([0,90,0])
        ChamferedCylinder(r1=2/2, r2=1/16,
                 h=LatchCollarLength(),
                 $fn=60);

        // Flat top
        translate([0, -(BarrelSleeveRadius()), 0])
        ChamferedCube([LatchCollarLength(),
                       (BarrelSleeveRadius())*2,
                       FrameBoltZ()
                         -FrameUpperBoltRadius()
                         -WallFrameUpperBolt()],
                      r=1/16);
      }

      union() {

        // Extractor Support
        for (R = ExtractorAngles()) rotate([R,0,0])
        translate([0,
                   -(LatchRodRadius()+ExtractorWall()),
                   ExtractorGuideZ()-(ExtractorWidth()/2)-ExtractorWall()])
        ChamferedCube([LatchCollarLength(),
                       (LatchRodRadius()+ExtractorWall())*2,
                       BarrelSleeveRadius()+0.5],
                       r=1/16);

        // Latch support
        LatchSupport();
        LatchFlatTop();
        LatchTabs();
      }
    }

    // Set screws
    for (R = [90,-90]) rotate([R,0,0])
    translate([0.5,0,BarrelSleeveRadius()])
    mirror([1,0,0])
    NutAndBolt(bolt=GPBolt(),
               boltLength=0.5+ManifoldGap(2),
               head="none", nut="heatset",
               teardrop=true,
               clearance=0.005);

    for (X = [0,-0.5]) translate([X,0,0])
    ExtractorAssembly(cutter=true);

    Barrel(cutter=true);


    Latch(cutter=true);
    *LatchSpring(cutter=true);
    LatchRod(cutter=true);
  }

}

module BarrelLatchCollar_print() {
  rotate([0,90,0])
  translate([-LatchCollarLength(),0,0])
  BarrelLatchCollar();
}

module BarrelPivotCollar(length=((PivotRadius()+WallPivot())*2),
                         debug=false, alpha=1, cutter=false) {

  color("DarkSlateBlue", alpha)
  DebugHalf(enabled=!cutter&&debug) RenderIf(!cutter)
  difference() {
    union() {

      // Around the barrel
      translate([PivotX()-(PivotRadius()+WallPivot()),0,BarrelOffsetZ()])
      rotate([0,90,0])
      ChamferedCylinder(r1=BarrelSleeveRadius()+WallBarrel(), r2=1/16,
               h=length+0.625,
               $fn=60);

      // Latch components
      translate([PivotX()-(PivotRadius()+WallPivot()), 0, 0]) {
        LatchFlatTop(length=length+0.625);

        LatchSupport(length=length, width=0.75);
      }

      // Set screw support
      translate([PivotX()-(PivotRadius()+WallPivot()),
                  -PivotWidth()/2, 0])
      ChamferedCube([length+0.625,
                     PivotWidth(),
                     ActionRodZ()+(ActionRodWidth())+WallActionRod()],
                    r=1/16);

      // Pivot support
      hull() {
        translate([PivotX(), -PivotWidth()/2, PivotZ()])
        rotate([-90,0,0])
        ChamferedCylinder(r1=PivotRadius()+WallPivot(), r2=1/16,
                           h=PivotWidth());

        translate([PivotX()-(PivotRadius()+WallPivot()), -PivotWidth()/2, 0])
        ChamferedCube([(PivotRadius()+WallPivot())*2,
                       PivotWidth(),
                       BarrelRadius()+WallBarrel()],
                      r=1/16);
      }
    }

    // Set screws
    for (M =[0,1]) mirror([0,0,M])
    translate([PivotX()+PivotRadius()+WallPivot()+(0.625/2),0,BarrelRadius()])
    NutAndBolt(bolt=GPBolt(),
               boltLength=2+ManifoldGap(2),
               head="none", nut="heatset",
               teardrop=true,
               clearance=0.005);

    // Pivot hole
    translate([PivotX(), 0, PivotZ()])
    rotate([90,0,0])
    cylinder(r=PivotRadius(), h=3, center=true);

    Barrel(cutter=true);

    translate([0,0,ActionRodZ()])
    ActionRod(cutter=true,
              length=PivotX()+PivotRadius()+WallPivot());

    LatchRod(cutter=true);
  }

}

module BarrelPivotCollar_print() {
  rotate([0,-90,0])
  translate([-PivotX()+(PivotRadius()+WallPivot()),0,0])
  BarrelPivotCollar();
}

module Foregrip(length=ForegripLength(), alpha=1) {
  color("Tan",alpha) render()
  difference() {
    union() {
      difference() {

        translate([ForegripOffsetX()+ChargerTravel(),0,LatchRodZ()-0.5])
        rotate([0,90,0])
        PumpGrip(length=length);

        // Cut off the top for the flat cap
        translate([ForegripOffsetX()+ChargerTravel(), -1, LatchFlatZ()-0.25])
        cube([length+0.125, 2, abs(LatchFlatZ())]);
      }


      // Flat cap
      translate([ForegripOffsetX()+ChargerTravel(),
                 -(LatchFlatWidth()/2),
                 LatchFlatZ()])
      mirror([0,0,1])
      ChamferedCube([length,
                     LatchFlatWidth(),
                     0.5],
                     r=1/16);
    }

    for(X = [0,ChargerTravel()+0.75]) translate([X,0,0])
    LatchTabs(cutter=true);

    LatchSupport(length=PivotX()+2, cutter=true);

    LatchRod(cutter=true);

    Barrel(cutter=true, clearance=PipeClearanceLoose());
  }
}

module Foregrip_print() {
  rotate([0,90,0])
  translate([-ForegripLength(),0,0])
  translate([-(ForegripOffsetX()+ChargerTravel()),0,-(LatchRodZ()-0.5)])
  Foregrip();
}


module BreakActionAssembly(receiverLength=12, pipeAlpha=1,
                           pivotFactor=0, extractFactor=0, chargeFactor=0, lockFactor=0,
                           stock=true, tailcap=false,
                           debug=false) {

  BreakActionForend(debug=debug);

  translate([0,0,0]) {
    RecoilPlateFiringPinAssembly();
    RecoilPlate(debug=debug);
    BreakActionRecoilPlateHousing();
  }

  // Pivoting barrel assembly
  BreakActionPivot(factor=pivotFactor) {

    translate([-(ChargerTravel()*chargeFactor),0,0]) {
      BarrelForegripCollar();

      translate([0,0,ActionRodZ()])
      ActionRod(length=5.25+ChargerTravel());
    }

    translate([0.5*lockFactor,0,0]) {
      LatchRod();
      LatchScrews();
      Latch(debug=debug);
      LatchFront(debug=debug);
    }

    // Pivot Pin
    %translate([PivotX(), 0, PivotZ()])
    rotate([90,0,0])
    cylinder(r=5/16/2, h=3, center=true);

    Barrel(debug=debug);

    translate([-ExtractorTravel()*extractFactor,0,0]) {
      ExtractorAssembly();
    }

    BarrelPivotCollar(debug=debug);

    LatchSpring();

    BarrelLatchCollar(debug=debug, alpha=1);

    translate([(0.5*lockFactor)-(ChargerTravel()*chargeFactor),0,0])
    Foregrip();

    *translate([BarrelLength()-1,0,0])
    Bipod();
  }
}

if (_RENDER == "Assembly") {
  BreakActionAssembly(debug=_DEBUG_ASSEMBLY,
                      pivotFactor=Animate(ANIMATION_STEP_UNLOAD)
                                 -Animate(ANIMATION_STEP_LOAD),
                      chargeFactor=Animate(ANIMATION_STEP_CHARGE)
                                 -Animate(ANIMATION_STEP_CHARGER_RESET),
                      lockFactor=Animate(ANIMATION_STEP_UNLOCK)
                                 -Animate(ANIMATION_STEP_LOCK),
                      extractFactor=Animate(ANIMATION_STEP_UNLOAD)
                                 -Animate(ANIMATION_STEP_LOAD));


  FrameSpacer(length=FrameForendExtension());


  translate([RecoilPlateRearX(),0,0]) {


    FrameBolts(length=FrameBoltLength());

    //translate([FiringPinMinX(),0,0])
    HammerAssembly(travelFactor=Animate(ANIMATION_STEP_FIRE)
                              - Animate(ANIMATION_STEP_CHARGE),
                   travel=-1);

    Receiver(pipeAlpha=1, buttstockAlpha=1, debug=_DEBUG_ASSEMBLY,
             triggerAnimationFactor=Animate(ANIMATION_STEP_TRIGGER)
                            -Animate(ANIMATION_STEP_TRIGGER_RESET));
  }
}

scale(25.4) {

  if (_RENDER == "BarrelPivotCollar")
  BarrelPivotCollar_print();

  if (_RENDER == "BarrelLatchCollar")
  BarrelLatchCollar_print();

  if (_RENDER == "RecoilPlateHousing")
  BreakActionRecoilPlateHousing_print();

  if (_RENDER == "Forend")
  BreakActionForend_print();

  if (_RENDER == "Foregrip")
  Foregrip_print();

  if (_RENDER == "Extractor")
  Extractor_print();

  if (_RENDER == "Latch")
  Latch_print();

  if (_RENDER == "LatchFront")
  LatchFront_print();
}
