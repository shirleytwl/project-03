class ReportsController < ApplicationController
  def index
    tags = Tag.all
    @details = []

    tags.each do |tag|
      data = Hash.new
      data[:tag_name] = tag.name
      prep = []

      case params[:duration]
      when 'year'
        p 'year'
        tag.ingredients.each do |ingredient|
          if ingredient.user == current_user && ingredient.removed == true && ingredient.updated_at >= Date.today - 1.year && ingredient.updated_at < Date.today
            prep.push(ingredient.quantity_left.to_f/ingredient.quantity.to_f)
            data[:tag] = tag
          end
        end
      when 'quarter'
        p 'quarter'
        tag.ingredients.each do |ingredient|
          if ingredient.user == current_user && ingredient.removed == true && ingredient.updated_at >= Date.today - 3.month && ingredient.updated_at < Date.today
            prep.push(ingredient.quantity_left.to_f/ingredient.quantity.to_f)
            data[:tag] = tag
          end
        end
      when 'month'
        p 'month'
        tag.ingredients.each do |ingredient|
          if ingredient.user == current_user && ingredient.removed == true && ingredient.updated_at >= Date.today - 1.month && ingredient.updated_at < Date.today
            prep.push(ingredient.quantity_left.to_f/ingredient.quantity.to_f)
            data[:tag] = tag
          end
        end
      when 'week'
        p 'week'
        tag.ingredients.each do |ingredient|
          if ingredient.user == current_user && ingredient.removed == true && ingredient.updated_at >= Date.today - 1.week && ingredient.updated_at < Date.today
            prep.push(ingredient.quantity_left.to_f/ingredient.quantity.to_f)
            data[:tag] = tag
          end
        end
      when 'day'
        p 'day'
        tag.ingredients.each do |ingredient|
          if ingredient.user == current_user && ingredient.removed == true && ingredient.updated_at >= Date.today - 1.day && ingredient.updated_at < Date.today
            prep.push(ingredient.quantity_left.to_f/ingredient.quantity.to_f)
            data[:tag] = tag
          end
        end
      else
        p 'all'
        tag.ingredients.each do |ingredient|
          if ingredient.user == current_user && ingredient.removed == true
            prep.push(ingredient.quantity_left.to_f/ingredient.quantity.to_f)
            data[:tag] = tag
          end
        end
      end

      if prep.any?
        data[:waste] = (prep.sum/prep.length*100).round(2);
        data[:consumed] = 100 - data[:waste]

        @details.push(data)
      end

      if params[:wastage] == 'desc'
        @details = @details.sort{|a,b| a[:waste] <=> b[:waste]}.reverse
      else
        @details = @details.sort{|a,b| a[:waste] <=> b[:waste]}
      end

    end
  end

  def show
    tag=Tag.find(params[:id])

    @data=scatterChart(tag)
    @options = scatterOptions

  end

  private def scatterChart (tag)
    details={:datasets => []}

    tag.ingredients.each do |ingredient|
      data = {:label => ingredient.name, :borderColor=> '', :backgroundColor => '', :data => [{:x => ((ingredient.quantity_left.to_f/ingredient.quantity.to_f)*100).round(2)}]}
      data[:data].first[:y] = 100.0 - data[:data].first[:x]

      if data[:data].first[:x] > 20
        data[:borderColor] = '#346102'
        data[:backgroundColor] = 'rgba(111, 150, 55, 1)'
      else
        data[:borderColor] = '#802E00'
        data[:backgroundColor] = 'rgba(190, 94, 40, 1)'
      end

      details[:datasets].push(data)
    end
    return details
  end

  private def scatterOptions
    options = {
      :responsive => true,
      :maintainAspectRatio => false,
      :width => 300,
      :height => 300,
      :legend => {
            :display => false
      },
      :scales => {
        :yAxes => [{
          :scaleLabel => {
            :display => true,
            :labelString => "Food Waste(%)"
          }
        }],
        :xAxes => [{
          :scaleLabel => {
            :display => true,
            :labelString => "Food Consumed(%)"
          }
        }]
      },
      :tooltips => {
        :callbacks => {
          :label => "function(tooltipItem, data) {
            var label = data.datasets[tooltipItem.datasetIndex].label;
            return label;
          }",
          :afterLabel => "function(tooltipItem, data) {
            var label = ['Wasted(%): ' + tooltipItem.yLabel  + '%', 'Consumed(%): ' + tooltipItem.xLabel + '%'];
            return label;
          }"
        }
      }
    }
  end
end