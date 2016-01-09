local lfs = require 'lfs'

local util = require 'loverocks.util'
local purge  = require 'loverocks.commands.purge'

local cwd = lfs.currentdir()
describe("loverocks install", function()
	local Install = require 'loverocks.commands.install'
	require 'spec.test_config'()
	setup(function()
		local New = require 'loverocks.commands.new'
		New.run {
			project      = "my-project",
			template     = "love9",
			love_version = "0.9.2",
		}
		lfs.chdir("my-project")
	end)

	teardown(function()
		lfs.chdir(cwd)
		assert(util.rm("my-project"))
	end)

	it("parses command line arguments correctly", function()
		local argparse = require 'loverocks.argparse'
		local parser = argparse()
		Install.build(parser)

		assert.same(
			{packages = {'inspect'}},
			parser:parse{'inspect'})

		assert.same(
			{packages = {'inspect', 'argparse'}},
			parser:parse{'inspect', 'argparse'})

		assert.same(
			{packages = {'inspect'}, only_server = "wat"},
			parser:parse{'inspect', '--only-server', 'wat'})

		assert.same(
			{packages = {'inspect'}, only_deps = true},
			parser:parse{'inspect', '--only-deps'})

		assert.same(
			{packages = {'inspect'}, server = 'wat'},
			parser:parse{'inspect', '--server', 'wat'})

		assert.same(
			{packages = {'inspect'}, server = 'wat'},
			parser:parse{'inspect', '-s', 'wat'})
	end)

	it("Can install normal rocks", function()
		finally(function()
			purge.run()
		end)
		Install.run {
			packages = {"inspect"},
			only_server = cwd .. "/test-repo"
		}
		assert.equal(type(loadfile(ROCKSDIR .. "/share/lua/5.1/inspect.lua")()), 'table')
	end)
end)
