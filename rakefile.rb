# This rakefile provides some support to handle multiple moodle instances
# on a given webserver
# see readme for details.

SCRIPT_ROOT   = File.dirname(__FILE__)
BACKUP_FOLDER = %Q{#{SCRIPT_ROOT}/../moodle_backups}


class MoodleRakeHelper

  def initialize
    @scriptroot = SCRIPT_ROOT
  end

  def doBackup(instance)
    puts "starting to backup #{instance}"
  end

  def getInstanceNames
    candidates = Dir["#{@scriptroot}/../*/config.php"]
    instances  = candidates.map { |candidate| getInstanceName(candidate) }.compact
    instances
  end

  def getInstanceName(candidate)
    result = nil
    result = File.basename(File.dirname(candidate)) if isInstance?(candidate)
  end

  def isInstance?(candidate)
    begin
      config = File.open(candidate).read
      result = false
      result = true if config.include?("<?php  // Moodle configuration file")
    rescue Exception => e
      throw "could not read instance config: #{e.message}"
    end

  end

  def loadInstance(instance)
    config_filename = "#{@scriptroot}/../#{instance}/config.php"
    throw "not a valid moodle instance: #{instance}" unless isInstance?(config_filename)

    result = MoodleInstance.new(instance, config_filename)

    result
  end
end

class MoodleInstance
  def initialize(name, configfilename)
    @attributes              = {}
    @attributes[:name]       = name
    @attributes[:moodlecode] = File.dirname(configfilename)

    # backup filestrategy is defined here.
    @timestamp               = Time.now.strftime("%Y-%m-%d_%H%M%S")
    @backupdir               = BACKUP_FOLDER

    FileUtils.mkdir_p(@backupdir)
    @backupbase = %Q{#{@backupdir}/#{@attributes[:name]}_#{@timestamp}}

    parse(configfilename)
  end


  def to_s
    "Moodle Instance: #{attributes[:name]}"
  end

  def backup_database

    #todo handle db prefix
    #todo proper error handling

    dbuser = @attributes[:dbuser]
    dbhost = @attributes[:dbhost]
    dbpass = @attributes[:dbpass]
    dbname = @attributes[:dbname]

    # see https://docs.moodle.org/20/en/Site_backup

    cmd    = %Q{mysqldump -u #{dbuser} -h'#{dbhost}' -p'#{dbpass}' -C -Q -e --create-options '#{dbname}' | gzip -9 > '#{mk_backup_filename('database')}'}
    system cmd

    nil
  end

  def backup_files

    #todo handle db prefix
    #todo proper error handling

    dataroot = @attributes[:dataroot]

    dataroot_dirname = File.dirname(dataroot)
    dataroot_files   = File.basename(dataroot)

    cd(dataroot_dirname) do
      cmd = %Q{tar -cvzf '#{mk_backup_filename('files')}' '#{dataroot_files}'}
      system cmd
    end
    nil
  end

  def backup_moodlecode
    moodlecode = @attributes[:moodlecode]

    cmd = %Q{tar -cvzf #{mk_backup_filename('moodlecode')} '#{moodlecode}'}
    system cmd

    nil
  end


  private

  def mk_backup_filename(part)
    %Q{#{@backupbase}_#{part}.gz}
  end

  def parse(configfilename)
    config        = File.open(configfilename).read
    entrypatterrn = /\$CFG->(\w+) \s*=\s*'  ([^']+)  ';/x

    config.scan(entrypatterrn).each do |match|
      @attributes[match[0].to_sym] = match[1]
    end

    nil
  end

end

@moodle = MoodleRakeHelper.new

################################################################


desc "this help"
task :default do
  sh 'rake -T'
end


desc 'show instances'
task :showInstances do
  puts @moodle.getInstanceNames
end

desc 'show available backups'
task :showBackups do
  backupfiles = Dir["#{BACKUP_FOLDER}/*_files.gz"]
  backupnames = backupfiles.map{|f| File.basename(f, "_files.gz")}
  puts backupnames
end


desc 'backup data and code  an instance'
task :backup, [:instance] do |task, args|
  begin
    instance = @moodle.loadInstance(args[:instance])
    puts "instance found: #{args[:instance]}"

    instance.backup_database
    instance.backup_files
    instance.backup_moodlecode

    # rescue Exception => e
    #   puts "not a valid moodle instance: #{args[:instance]}"
    #   puts e
    #   puts caller
  end
end


desc 'backup data an instance'
task :backupData, [:instance] do |task, args|
  begin
    instance = @moodle.loadInstance(args[:instance])
    puts "instance found: #{args[:instance]}"

    instance.backup_database
    instance.backup_files

    # rescue Exception => e
    #   puts "not a valid moodle instance: #{args[:instance]}"
    #   puts e
    #   puts caller
  end
end


desc 'backup code of an instance'
task :backupCode, [:instance] do |task, args|
  begin
    instance = @moodle.loadInstance(args[:instance])
    puts "instance found: #{args[:instance]}"

    instance.backup_moodlecode

    # rescue Exception => e
    #   puts "not a valid moodle instance: #{args[:instance]}"
    #   puts e
    #   puts caller
  end
end


