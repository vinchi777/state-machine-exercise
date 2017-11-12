require 'highline'

module ResumePrompt
  MAIN_MENU_OPTIONS = ['enter name', 'work experience', 'exit']
  WORK_EXP_MENU_OPTIONS = ['current job position', 'current company', 'back to menu']

  def display_main_menu
    cli.say 'Main Menu'

    full_name = " (#{@first_name} #{@last_name})" if (@first_name || @last_name)
    cli.say "1. Enter Name#{ full_name }"
    cli.say "2. Work Experience"
    cli.say "3. Exit"

    answer = cli.ask "select 1 or 'enter name'"
    go_next(answer)
  end

  def ask_full_name
    cli.say 'Enter Name'
    @first_name = cli.ask "Enter First Name: "
    @last_name = cli.ask "Enter Last Name: "

    fire_events(:start)
  end

  def ask_work_experience
    fire_events(:start_work_experience_current)
  end

  def display_result
    cli.say "#{@first_name} #{@last_name} - Company: #{@company}, Job Position: #{@job_position} "
  end

  def go_next(answer)
    option = MAIN_MENU_OPTIONS.find{|opt| opt == answer.downcase}
    option = MAIN_MENU_OPTIONS[answer.to_i - 1] if answer.match /^[1-3]$/ # Check if input is between 1-3

    cli.say('Invalid Option') if option.nil?

    event = case option
    when 'enter name'
      :enter_name
    when 'work experience'
      :enter_experience
    when 'exit'
      :quit
    else
      :start
    end

    fire_events(event)
  end

  # Work menu state functions

  def display_work_exp_menu
    return if !state?(:work_experience)

    job_position = " (#{@job_position})" if @job_position
    company = " (#{@company})" if @company

    cli.say "1. Current Job Position#{job_position}"
    cli.say "2. Current Company#{company}"
    cli.say "3. Back to Menu"

    answer = cli.ask "select 1 or 'current job position'"
    go_next_within_work_menu(answer)
  end

  def ask_current_job_position
    @job_position = cli.ask "Enter Current Job Position: "
    fire_events(:start_work_experience_current)
  end

  def ask_current_company
    @company = cli.ask "Enter Current Company: "
    fire_events(:start_work_experience_current)
  end

  def go_next_within_work_menu(answer)
    option = WORK_EXP_MENU_OPTIONS.find{|opt| opt == answer.downcase}
    option = WORK_EXP_MENU_OPTIONS[answer.to_i - 1] if answer.match /^[1-3]$/ # Check if input is between 1-3

    cli.say('Invalid Option') if option.nil?

    event = case option
    when 'current job position'
      :enter_job_position_current
    when 'current company'
      :enter_company_current
    when 'back to menu'
      :start
    else
      :start_work_experience_current
    end

    fire_events(event)
  end

  # Clear previous screens
  def clear
    puts "\e[H\e[2J"
  end

  def cli
    @cli ||= HighLine.new
  end

end
