#!/usr/bin/env ruby
require 'fileutils'
require 'pathname'
require 'date'

class MoSnapper
  attr_accessor :user, :path, :liked

  class << self
    def call
      new.call
    end
  end

  def initialize
    self.user = `whoami`.strip
    self.path = Pathname.new File.join(Dir.pwd, user)
    self.liked = false
    path.mkdir unless path.exist?
  end

  def call
    welcome
    while !liked
      capture
      convert
      preview
      confirm
    end
    commit
  end

  private
  def todays_tiff 
    "#{Date.today.to_s}.tiff"
  end

  def todays_jpg 
    "#{Date.today.to_s}.jpg"
  end

  def welcome
    puts <<-eos
................................................................................
.............MMM............MMMMMMMMM,...MMMMMMMMMM,..........MMMM..............
...........MMM...........MMMMMMMMMMMMMMMMMMMMMMMMMMMMM...........MMM............
..........MMM.........IMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN.........MMM...........
..........MMM.......MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM.......MMM...........
..........MMMM..OMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM=8MMMMM...........
..........MMMMMMMMMMMMMMMMMMMMMMMMMMMMM.MMMMMMMMMMMMMMMMMMMMMMMMMMMMM...........
...........MMMMMMMMMMMMMMMMMMMMMMMMMM....8MMMMMMMMMMMMMMMMMMMMMMMMMM............
.......   ..MMMMMMMMMMMMMMMMMMMMMM..........MMMMMMMMMMMMMMMMMMMMMM...  .........
.......    ....MMMMMMMMMMMMMMZ...................MMMMMMMMMMMMMM.....    ........

    eos
  end

  def capture
    puts "Please assume the stache position..."
    `open -W MoShot.app`
    FileUtils.mv File.expand_path('~/Desktop/Movember.tiff'), path.join(todays_tiff)
  end

  def convert
    unless system("convert '#{path.join(todays_tiff)}' '#{path.join(todays_jpg)}'")
      puts ''
      puts 'egads, an error!'
      puts 'It could be because your stache is getting so horrendous :^{'
      puts 'But more likely, you need to install ImageMagick with tiff support:'
      puts ''
      puts 'brew install libtiff'
      puts 'brew install imagemagick --with-libtiff'
      exit
    end
    File.delete path.join(todays_tiff)
  end

  def preview
    `open -a Preview "#{path.join(todays_jpg)}"`
  end

  def confirm
    print "Lookin' gooooood? "
    resp = gets.strip
    self.liked = resp =~ /y(es)?/i
  end

  def commit
    `git add #{path.join(todays_jpg)}`
    `git commit -m "Stache shot ##{Date.today.day} for #{user}!"`
    `git push`
    puts "signed, sealed, pushed!"
  end
end

MoSnapper.call
