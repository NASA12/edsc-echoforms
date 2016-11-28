window.sharedBehaviorForControls = (template, options={}) ->

  it 'is tagged as a control', ->
    template.form($('#dom'))
    expect($('#control')).toHaveClass('echoforms-control')

  it "displays its label", ->
    template.form($('#dom'), attributes: 'label="Control label"')
    expect($('#control > .echoforms-label')).toHaveText('Control label')

  it "displays help", ->
    template.form($('#dom'), children: '<help>Helpful text</help>')
    expect($('#control > .echoforms-help')).toHaveText('Helpful text')

  unless options['skip_input_specs']
    it "uses the default value contained in the model", ->
      template.form($('#dom'),
        model: '<prov:default>Default value</prov:default>',
        attributes: 'ref="prov:default"')
      expect($('#control :input').val()).toBe('Default value')

    it "is initially blank when the model has no default value", ->
      template.form($('#dom'),
        model: '<prov:default />',
        attributes: 'ref="prov:default"')
      expect($('#control :input').val()).toBe('')

  describe '"relevant" attribute', ->
    it "contains an xpath which hides the control when it evaluates to false", ->
      template.form($('#dom'), attributes: 'relevant="prov:reference != \'hidden\'"')
      expect($('#control')).toBeVisible()
      $('#reference :input').val('hidden').change()
      expect($('#control')).toBeHidden()
      $('#reference :input').val('visible').change()
      expect($('#control')).toBeVisible()

    it "may contain element selectors, which are interpreted as booleans", ->
      template.form($('#dom'), attributes: 'relevant="[prov:reference!=\'hidden\']"')
      expect($('#control')).toBeVisible()
      $('#reference :input').val('hidden').change()
      expect($('#control')).toBeHidden()
      $('#reference :input').val('visible').change()
      expect($('#control')).toBeVisible()

  unless options['skip_input_specs']
    describe '"required" attribute', ->
      it "contains an xpath which requires the control to have a value when it evaluates to true", ->
        template.form($('#dom'),
          model: '<prov:value/>',
          attributes: 'required="prov:reference=\'required\'" ref="prov:value"')
        expect('#control').not.toHaveError('Required field')
        $('#reference :input').val('required').change()
        expect('#control').toHaveError('Required field')
        $('#reference :input').val('optional').change()
        expect('#control').not.toHaveError('Required field')

      it "produces no error if the control has a non-empty value", ->
        template.form($('#dom'),
          model: '<prov:value/>',
          attributes: 'required="prov:reference=\'required\'" ref="prov:value"')
        $('#reference :input').val('required').change()
        expect('#control').toHaveError('Required field')
        $('#control :input').val('value').change()
        expect('#control').not.toHaveError('Required field')
        $('#control :input').val('').change()
        expect('#control').toHaveError('Required field')

    describe '"reaodnly" attribute', ->
      it "contains an xpath which causes the control to become readonly", ->
        template.form($('#dom'), attributes: 'readonly="prov:reference=\'readonly\'"')
        expect('#control').not.toBeReadonly()
        $('#reference :input').val('readonly').change()
        expect('#control').toBeReadonly()
        $('#reference :input').val('').change()
        expect('#control').not.toBeReadonly()

  describe '"pattern" constriants', ->
    constraints =     """
      <constraints>
        <constraint>
          <pattern>[0-9]+</pattern>
          <alert>Must be numeric</alert>
        </constraint>
      </constraints>
      """

    unless options['skip_input_specs']
      it "displays the given error message when the control's value does not match the given pattern", ->
        template.form($('#dom'), children: constraints)
        $('#control :input').val('alphabetic').change()
        expect('#control').toHaveError('Must be numeric')

      it "displays no error when the control's value matches the given pattern", ->
        template.form($('#dom'), children: constraints)
        $('#control :input').val('12345').change()
        expect('#control').not.toHaveError('Must be numeric')

      it "displays no error when the control is left blank", ->
        template.form($('#dom'),
          children: constraints,
          model: '<prov:value/>',
          attributes: 'ref="prov:value"')
        expect('#control').not.toHaveError('Must be numeric')

  describe '"xpath" constriants', ->
    constraints = """
      <constraints>
        <constraint>
          <xpath>prov:reference != 'invalid'</xpath>
          <alert>Invalid!</alert>
        </constraint>
      </constraints>
    """

    it "displays the given error message when the given XPath evaluates to false", ->
      template.form($('#dom'), children: constraints)
      expect('#control').not.toHaveError('Invalid!')
      $('#reference :input').val('invalid').change()
      expect('#control').toHaveError('Invalid!')

    it "displays no error when the given XPath evaluates to true", ->
      template.form($('#dom'), children: constraints)
      $('#reference :input').val('valid').change()
      expect('#control').not.toHaveError('Invalid!')
