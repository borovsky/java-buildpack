# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'java_buildpack/component/base_component'

describe JavaBuildpack::Component::BaseComponent do

  let(:context) { { application: 'application', configuration: 'configuration', droplet: 'droplet' } }

  let(:base_component) { StubBaseComponent.new 'Test Name', context }

  it 'should assign application to an instance variable' do
    expect(base_component.application).to eq('application')
  end

  it 'should assign component name to an instance variable' do
    expect(base_component.component_name).to eq('Test Name')
  end

  it 'should assign configuration to an instance variable' do
    expect(base_component.configuration).to eq('configuration')
  end

  it 'should assign droplet to an instance variable' do
    expect(base_component.droplet).to eq('droplet')
  end

  it 'should assign parsable_component_name to an instance variable' do
    expect(base_component.parsable_component_name).to eq('test-name')
  end

  it 'should fail if methods are unimplemented' do
    expect { base_component.detect }.to raise_error
    expect { base_component.compile }.to raise_error
    expect { base_component.release }.to raise_error
  end

end

class StubBaseComponent < JavaBuildpack::Component::BaseComponent

  attr_reader :application, :component_name, :configuration, :droplet, :parsable_component_name

end
