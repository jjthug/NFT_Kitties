
var colors = Object.values(allColors())

var defaultDNA = {
    "headcolor" : 10,
    "eyeColorVar" : 13,
    "pupilColorVar" : 96,
    "mouthColorVar" : 10,
    //Cattributes
    "eyesShape" : 1,
    "decorationPattern" : 1,
    "decorationMidcolor" : 13,
    "decorationSidescolor" : 13,
    "animation" :  1,
    "lastNum" :  1
    }

// when page load
$( document ).ready(function() {
  $('#dnabody').html(defaultDNA.headColor);
  $('#dnaeye').html(defaultDNA.eyeColorVar);
  $('#dnapupil').html(defaultDNA.pupilColorVar);
  $('#dnamouth').html(defaultDNA.mouthColorVar);
    
//   $('#dnashape').html(defaultDNA.eyesShape)
//   $('#dnadecoration').html(defaultDNA.decorationPattern)
//   $('#dnadecorationMid').html(defaultDNA.decorationMidcolor)
//   $('#dnadecorationSides').html(defaultDNA.decorationSidescolor)
//   $('#dnaanimation').html(defaultDNA.animation)
//   $('#dnaspecial').html(defaultDNA.lastNum)

  renderCat(defaultDNA)
});

function getDna(){
    var dna = ''
    dna += $('#dnabody').html()
    dna += $('#dnaeye').html()
    dna += $('#dnapupil').html()
    dna += $('#dnamouth').html()
    dna += $('#dnashape').html()
    dna += $('#dnadecoration').html()
    dna += $('#dnadecorationMid').html()
    dna += $('#dnadecorationSides').html()
    dna += $('#dnaanimation').html()
    dna += $('#dnaspecial').html()

    return parseInt(dna)
}

function renderCat(dna){
    headColor(colors[dna.headcolor],dna.headcolor)
    $('#bodycolor').val(dna.headcolor)
}

// Changing cat colors
$('#bodycolor').change(()=>{
    var colorVal = $('#bodycolor').val()
    bodycolor(colors[colorVal],colorVal)
})


$('#eyeColor').change(()=>{
  var colorVal = $('#eyeColor').val()
  eyeColor(colors[colorVal],colorVal)
})

$('#pupilColor').change(()=>{
  var colorVal = $('#pupilColor').val()
  pupilColor(colors[colorVal],colorVal)
})

$('#mouthColor').change(()=>{
  var colorVal = $('#mouthColor').val()
  mouthColor(colors[colorVal],colorVal)
})
