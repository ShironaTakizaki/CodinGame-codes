STDOUT.sync = true # DO NOT REMOVE

#***************************************************************
class GameParamater
  def initialize()
    @cell = []
      # index: 0 is the center cell, the next cells spiral outwards
      # richness: 0 if the cell is unusable, 1-3 for usable cells
      # neigh_0..neigh_5: the index of the neighbouring cell for each direction
      
    @turn = \
      [:number_of_cells, :day, :nutrients, :sun, :score, :opp_sun, :opp_score, :opp_is_waiting, :num_trees,:number_of_possible_actions]\
      .zip([37, 0, 0, 0, 0, 0, 0, false, 0, 0]).to_h
      # day: the game lasts 24 days: 0-23
      # nutrients: the base score you gain from the next COMPLETE action
      # sun: your sun points
      # score: your current score
      # opp_sun: opponent's sun points
      # opp_score: opponent's score
      # opp_is_waiting: whether your opponent is asleep until the next day
      # num_trees: the current amount of trees
      # number_of_possible_actions: all legal actions
      
    @tree = []
      # cell_index: location of this tree
      # size: size of this tree: 0-3
      # is_mine: 1 if this is your tree
      # is_dormant: 1 if this tree is dormant
    
    @able = []
      # possible_actions: try printing something from here to start with

    init_local_param
  end
    
  def init_local_param
    @able_table = []
    @nummytree = [0, 0, 0, 0]
    @treecells = []
    @nilcells = []
    @seedablecells = []
    @seedablecommand = []
    @growablecells = [[],[],[],[]] # 3 is COMPLETABLE
    @sun_of_afteract = {seed:0, grow0:0, grow1:0, grow2:0, complete:0}
  end
  
  def set_geme_param
    @turn[:number_of_cells] = gets.to_i
    @cell = @turn[:number_of_cells].times.map{\
      [:index, :richness, :neigh_0, :neigh_1, :neigh_2, :neigh_3, :neigh_4, :neigh_5]\
      .zip(gets.split.map(&:to_i)).to_h}
  end
  
  def set_param
    memo = 5.times.map{gets.split.map(&:to_i)}.flatten
    @turn[:day] = memo[0]
    @turn[:nutrients] = memo[1]
    @turn[:sun] = memo[2]
    @turn[:score] = memo[3]
    @turn[:opp_sun] = memo[4]
    @turn[:opp_score] = memo[5]
    @turn[:opp_is_waiting] = memo[6] == 1
    @turn[:num_trees] = memo[7]
    
    @tree = @turn[:num_trees].times.map{\
      [:cell_index, :size, :is_mine, :is_dormant]\
      .zip(gets.split.map.with_index{|x, i| i < 2 ?  x.to_i : x.to_i == 1}).to_h}

    @turn[:number_of_possible_actions] = gets.to_i
    @able = @turn[:number_of_possible_actions].times.map{gets.chomp}
    
    update_local_param
  end
  
  
  #★-------------------------------------------------------
  
  def update_local_param
    cells = @turn[:number_of_cells]
    
    @able_table = @able.map{|x| x.split}
    
    4.times do |i|
      @nummytree[i] = @tree.select{|x| \
        x[:size] == i && \
        x[:is_mine]}.size
    end
    
    @treecells = @tree.map{|x| x[:index]}
    
    @nilcells = (0..(cells - 1)).to_a - @treecells
    
    @seedablecells = @able_table \
      .select{|x| x[0] == "SEED"} \
      .map{|x| x[-1].to_i}.uniq.sort
    
    @seedablecommand = @able_table \
      .select{|x| x[0] == "SEED"} \
      .sort_by do |x|
        a = x[-1].to_i
        (a >= 7 ? a : (a + 19)) * 37 - x[1].to_i
      end.map{|x| x.join(" ")}
    
    4.times do |i|
      @growablecells[i] = @tree.select{|x| \
        x[:size] == i && \
        x[:is_mine] && !x[:is_dormant]} \
        .map{|x| x[:cell_index]}
    end
    
    @sun_of_afteract[:seed] = @turn[:sun] - (0 + @nummytree[0])
    @sun_of_afteract[:grow0] = @turn[:sun] - (1 + @nummytree[1])
    @sun_of_afteract[:grow1] = @turn[:sun] - (3 + @nummytree[2])
    @sun_of_afteract[:grow2] = @turn[:sun] - (7 + @nummytree[3])
    @sun_of_afteract[:complete] = @turn[:sun] - 4
  end
  
  # output status
  def get_status(group, index, param) # group: str, index: int, param: key
    case group
    when "cell"
      @turn[index][param]
    when "turn"
      @turn[param]
    when "tree"
      @tree[index][param]
    when "able"
      @able[index][param]
    else
      return nil
    end
  end

#----------------------------------------------------------
  # GROW cellIdx | SEED sourceIdx targetIdx | COMPLETE cellIdx | WAIT <message>
  
    #@able_table = []
    #@nummytree = [0, 0, 0, 0]
    #@treecells = []
    #@nilcells = []
    #@seedablecells = []
    #@seedablecommand = []
    #@growablecells = [[],[],[],[]] # 3 is COMPLETABLE
    #@sun_of_afteract = {seed:0, grow0:0, grow1:0, grow2:0, complete:0}
  
  def tactics    
    if @able.size == 1
      return "WAIT active nothing"
      
    elsif @turn[:day] == 0
      return @seedablecommand[0]

    elsif @turn[:day] == 21
      if @growablecells[3].size > 3
        return "COMPLETE " + @growablecells[3][-1].to_s
      elsif @growablecells[2].size > 0
        return "GROW " + @growablecells[2][0].to_s
      else
        return "WAIT COMPLETE"
      end
      
    elsif @turn[:day] == 22
      if @growablecells[2].size > 0
        return "GROW " + @growablecells[2][0].to_s
      else
        return "WAIT"
      end
      
    elsif @turn[:day] == 23 || @nummytree[3] > 3
      if @growablecells[3].size > 0
        return "COMPLETE " + @growablecells[3][-1].to_s
      else
        return "WAIT COMPLETE"
      end
      
    elsif @nummytree[0] == 0 \
        && @seedablecells.size > 0
      return @seedablecommand[0]
    
    elsif @growablecells[0].size > 0 && @nummytree[1] < 3
      return "GROW " + @growablecells[0][-1].to_s
    
    elsif (@nummytree[2] > 5 || @nummytree[3] + 1 < @nummytree[2]) \
        && @growablecells[2].size > 0
      return "GROW " + @growablecells[2][0].to_s
    
    elsif @nummytree[0] == 1 \
        && @seedablecells.size > 0
      return @seedablecommand[0]

    elsif @nummytree[1] > 1 \
        && @growablecells[1].size > 0
      return "GROW " + @growablecells[1][0].to_s
      
    elsif @growablecells[0].size > 0
      return "GROW " + @growablecells[0][-1].to_s
    
    else
      return "WAIT not Select"
    end
  end
end
#----------------------------------------------------------

#***************************************************************

st = GameParamater.new
st.set_geme_param

loop do
  st.set_param
  puts st.tactics
end
