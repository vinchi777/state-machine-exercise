require 'state_machine'
require 'highline'

class ResumeState
  attr_accessor :first_name, :last_name, :job_position, :company
  MAIN_MENU_OPTIONS = ['enter name', 'work experience', 'exit']
  WORK_EXP_MENU_OPTIONS = ['current job position', 'current company', 'back to menu']

  state_machine :state, initial: :main_menu do
    before_transition on: any, :do => :clear

    after_transition on: :enter_name, do: :ask_full_name
    after_transition on: :enter_experience, do: :ask_work_experience
    after_transition on: :quit, do: :display_result
    after_transition on: :start, do: :display_main_menu

    event :enter_name do
      transition :main_menu => :full_name
    end

    event :enter_experience do
      transition :main_menu => :work_experience
    end

    event :quit do
      transition :main_menu => :complete
    end

    event :start do
      transition all => :main_menu
    end
  end

  state_machine :work_state, initial: :work_menu, namespace: 'current'    do
    before_transition on: any, :do => :clear

    after_transition on: :enter_job_position, do: :ask_current_job_position
    after_transition on: :enter_company, do: :ask_current_company
    after_transition on: :start_work_experience, do: :display_work_exp_menu

    event :enter_job_position do
      transition :work_menu => :job_position
    end

    event :enter_company do
      transition :work_menu => :company
    end

    event :start_work_experience do
      transition all => :work_menu
    end
  end

  def initialize
    @cli = HighLine.new
    @first_name = nil
    @last_name = nil
    @company = nil
    @job_position = nil
    super()
  end

  def ask_full_name
    @cli.say 'Enter Name'
    @first_name = @cli.ask "Enter First Name: "
    @last_name = @cli.ask "Enter Last Name: "

    start
  end

  def ask_work_experience
    start_work_experience_current
  end

  def display_result
    @cli.say "#{@first_name} #{@last_name} - Company: #{@company}, Job Position: #{@job_position} "
  end

  def display_main_menu
    @cli.say 'Main Menu'

    full_name = " (#{@first_name} #{@last_name})" if (@first_name || @last_name)
    @cli.say "1. Enter Name#{ full_name }"
    @cli.say "2. Work Experience"
    @cli.say "3. Exit"

    answer = @cli.ask "select 1 or 'enter name'"
    go_next(answer)
  end

  def go_next(answer)
    option = MAIN_MENU_OPTIONS.find{|opt| opt == answer.downcase}
    option = MAIN_MENU_OPTIONS[answer.to_i - 1] if answer.match /^[1-3]$/ # Check if input is between 1-3

    @cli.say('Invalid Option') if option.nil?

    case option
    when 'enter name'
      enter_name
    when 'work experience'
      enter_experience
    when 'exit'
      quit
    else
      start
    end
  end

  # Work menu state functions
  
  def display_work_exp_menu
    return if !state?(:work_experience)

    job_position = " (#{@job_position})" if @job_position
    company = " (#{@company})" if @company

    @cli.say "1. Current Job Position#{job_position}"
    @cli.say "2. Current Company#{company}"
    @cli.say "3. Back to Menu"

    answer = @cli.ask "select 1 or 'current job position'"
    go_next_within_work_menu(answer)
  end

  def ask_current_job_position
    @job_position = @cli.ask "Enter Current Job Position: "
    start_work_experience_current
  end

  def ask_current_company
    @company = @cli.ask "Enter Current Company: "
    start_work_experience_current
  end

  def go_next_within_work_menu(answer)
    option = WORK_EXP_MENU_OPTIONS.find{|opt| opt == answer.downcase}
    option = WORK_EXP_MENU_OPTIONS[answer.to_i - 1] if answer.match /^[1-3]$/ # Check if input is between 1-3

    @cli.say('Invalid Option') if option.nil?

    case option
    when 'current job position'
      enter_job_position_current
    when 'current company'
      enter_company_current
    when 'back to menu'
      start
    else
      start_work_experience_current
    end
  end

  # Clear previous screens
  def clear
    puts "\e[H\e[2J"
  end

end
