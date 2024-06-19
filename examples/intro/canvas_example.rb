require 'rubygems'
require 'drp'

NUM_CANVASES = 8
CANVAS_SIZE = 200

class CanvasExample

  extend DRP::RuleEngine

  def initialize num_codons = 100
    @codons = Array.new(num_codons) { rand }
    @num_codons = num_codons
    @index = 0
  end

  def next_codon
    @index += 1
    @index = 0 if @index >= @num_codons
    @codons[@index]
  end

 begin_rules

  max_depth 4..24
  weight 1

  def start_rule
    start_rule + ctx_mv_list_prep
  end

  def ctx_mv_list_prep    
    ctx_begin + ctx_fill_style + ctx_stroke_style + ctx_mv_list + ctx_end
  end
  def ctx_mv_list
    ctx_mv_list + ctx_mv
  end

  def ctx_mv
    "ctx.#{mv_type}"
  end

  # this weight will apply to all following rule methods
  weight_fcd 0..1

  def mv_type
    "lineTo(#{loc},#{loc});"
  end
  def mv_type
    "moveTo(#{loc},#{loc});"
  end
  def mv_type
    "bezierCurveTo(#{loc},#{loc},#{loc},#{loc},#{loc},#{loc});"
  end
  
  def ctx_end
    "ctx.fill();"
  end
  def ctx_end
    "ctx.stroke();"
  end

 end_rules

  def loc
    map(0..CANVAS_SIZE).to_i
  end

  def ctx_fill_style
    "ctx.fillStyle=#{rgba}"
  end
  def ctx_stroke_style
    "ctx.strokeStyle=#{rgba}"
  end  
  def ctx_begin
    "ctx.beginPath();"
  end
  def rgba
    "'rgba(#{rgb_val},#{rgb_val},#{rgb_val},#{next_codon})';"
  end
  def rgb_val
    map(0..256).to_i
  end

  def default_rule_method
    ''
  end

end

def html script, body
  %{<html><head>
    <style>
      canvas {margin: 10px; border: solid black 1px}
      #drp {margin: 10px}
    </style>
    <script>#{script}</script></head>
    <body>#{body}</body></html>
  }
end
def js_draw_func
  "function(ctx){#{CanvasExample.new.start_rule}},\n"
end

script = %{
  window.onload = function() {
    for( var i = 0; i < #{NUM_CANVASES}; i++ ) { 
      var ctx = document.getElementById('cvs_' + i).getContext('2d');
      draw_funcs[i](ctx);
    }
  }
  var draw_funcs = [
}
NUM_CANVASES.times do |i|
  script += js_draw_func
end
script += "];"

body = ""
NUM_CANVASES.times do |i|
  body += %{<canvas id='cvs_#{i}' width="#{CANVAS_SIZE}" height="#{CANVAS_SIZE}"></canvas>}
end
puts html(script, body)
