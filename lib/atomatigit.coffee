Repo = RepoView = ErrorView = null

module.exports =
  config:
    debug:
      title: 'Debug'
      description: 'Toggle debugging tools'
      type: 'boolean'
      default: false
      order: 1
    pre_commit_hook:
      title: 'Pre Commit Hook'
      description: 'Command to run for the pre commit hook'
      type: 'string'
      default: ''
      order: 2
    show_on_startup:
      title: 'Show on Startup'
      description: 'Check this if you want atomatigit to show up when Atom is loaded'
      type: 'boolean'
      default: false
      order: 3
    display_commit_comparisons:
      title: 'Display Commit Comparisons'
      description: 'Display how many commits ahead/behind your branches are'
      type: 'boolean'
      default: true
      order: 4

  repo: null
  repoView: null

  startup_error_shown: false

  # Public: Package activation.
  activate: (state) ->
    @insertCommands()
    return @errorNoGitRepo() unless atom.project.getRepositories()[0]
    if atom.config.get('atomatigit.show_on_startup')
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'atomatigit:show')

  # Public: Close the atomatigit pane.
  hide: ->
    @repoView.detach() if @repoView.hasParent()
    atom.workspace.getActivePane().activate()

  # Internal: Append the repoView (if not already) and focus the pane
  append: ->
    atom.workspace.addRightPanel(item: @repoView) unless @repoView?.hasParent()
    @repoView.focus()

  # Public: Open (or focus) the atomatigit window.
  show: ->
    return @errorNoGitRepo() unless atom.project.getRepositories()[0]
    @loadClasses() unless Repo and RepoView
    @repo ?= new Repo()
    if !@repoView?
      @repoView = new RepoView(@repo)
      @repoView.InitPromise.then => @append()
    else
      @append()

  # Internal: Destroy atomatigit instance.
  deactivate: ->
    @repo.destroy()
    @repoView.destroy()

  # Internal: Display error message if the project is no git repository.
  errorNoGitRepo: ->
    ErrorView = require './views/error-view'
    new ErrorView(message: 'Project is no git repository!') if @startup_error_shown
    @startup_error_shown = true

  # Internal: Register package commands with atom.
  insertCommands: ->
    atom.commands.add 'atom-workspace', 'atomatigit:show', => @show()
    atom.commands.add 'atom-workspace', 'atomatigit:close', => @hide()

  # Internal: Load required classes on activation
  loadClasses: ->
    Repo      = require './models/repo'
    RepoView  = require './views/repo-view'
