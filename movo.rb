#!/usr/bin/env ruby
require 'fileutils'
require 'pathname'
require 'date'

class MoSnapper
  attr_accessor :user, :path, :response

  RESPONSES = [:initial, :liked, :redo, :quit]

  class << self
    def call
      new.call
    end
  end

  def initialize
    self.user = `whoami`.strip
    self.path = Pathname.new File.join(Dir.pwd, user)
    self.response = :initial
    path.mkdir unless path.exist?
  end

  def call
    welcome
    while !quit?
      if !todays_exists? || redo?
        capture
        convert
      end
      grayscale
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

  def todays_bw
    "#{Date.today.to_s}-bw.jpg"
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

  def todays_exists?
    File.exists? path.join(todays_jpg)
  end

  def quit?
    [:quit, :liked].include? self.response
  end

  def redo?
    response == :redo
  end

  def capture
    puts "Please assume the stache position..."
    `open -W MoShot.app`
    FileUtils.mv File.expand_path('~/Desktop/Movember.tiff'), path.join(todays_tiff)
  end

  def convert
    puts "Converting..."
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

  def grayscale
    `convert '#{path.join(todays_jpg)}' -colorspace Gray '#{path.join(todays_bw)}'`
  end

  def preview
    `open -a Preview "#{path.join(todays_bw)}"`
  end

  def confirm
    print "Lookin' gooooood? "
    case gets.strip
      when /y(es)?/i
        self.response = :liked
      when /q(uit)/i
        self.response = :quit
      else
        self.response = :redo
    end
  end

  def commit
    `git pull --rebase`
    `git add #{path.join(todays_jpg)} #{path.join(todays_bw)}`
    `git commit -m "Stache shot ##{Date.today.day} for #{user}!"`
    `git push`
    puts "signed, sealed, pushed!"
    puts ""
    puts "see the progress: http://lessonplanet.github.io/lp-movember/"
  end
end

MoSnapper.call
