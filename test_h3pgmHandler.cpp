
#include "lua.hpp" // luajit

#include <iostream>
#include <string>


using namespace std;

////////////////////////////////////////////////////////////////////////////////
////////// LuaWrap
////////////////////////////////////////////////////////////////////////////////

lua_State* LuaWrap_load(string filepath)
{

  lua_State *L = luaL_newstate();
  luaL_openlibs(L);
  
  int err = luaL_dofile(L,filepath.c_str());
  if (err != 0)
  {
    cout << "LUA CALL Error "<< err << ": " << lua_tostring(L,-1) << endl;
    return NULL; // todo should throw exception, or os.exit()
  }
  
  return L;
}


void LuaWrap_close(lua_State *L)
{
  lua_close(L);
}

////////////////////////////////////////////////////////////////////////////////
////////// h3pgm structures
////////////////////////////////////////////////////////////////////////////////


// todo random_seeds
struct RandomSeeds
{
  int LMLGenerator;
  int CellularTerrain;
  // todo
};

RandomSeeds RandomSeeds_pop(lua_State *L, int posindex) 
{ // WARNING: 'index' is not popped from the stack
  if (posindex < 0) // negative index given
    posindex = lua_gettop(L) + 1 +  posindex;
    
  RandomSeeds rs;
  lua_getfield(L, posindex, "LMLGenerator");
  rs.LMLGenerator = (int)lua_tonumber(L, -1);
  lua_pop(L,1);
  
  lua_getfield(L, posindex, "CellularTerrain");
  rs.CellularTerrain = (int)lua_tonumber(L, -1);
  lua_pop(L,1);
  
  return rs;
}

struct LMLInit 
{
  string zones;
  string features;
}; 

LMLInit LMLInit_pop(lua_State *L, int posindex) // http://stackoverflow.com/questions/18478379/how-to-work-with-tables-passed-as-an-argument-to-a-lua-c-function
{ // WARNING: 'index' is not popped from the stack
  if (posindex < 0) // negative index given
    posindex = lua_gettop(L) + 1 +  posindex;
  lua_getfield(L, posindex, "zones");
  lua_getfield(L, posindex, "features");
  // stack now has following: (for index==-1)
  //   -1 3 = features
  //   -2 2 = zones
  //   -3 1 = { zones='...', features='...' }
  string zones( lua_tostring(L, -2) ); // check if string omitted
  string features( lua_tostring(L, -1) ); // check if string omitted
  lua_pop(L,2);
  return {zones,features};
}

void LMLInit_push(lua_State *L, LMLInit lmlinit) // pushes lmlinit on the top of the stack
{ 
  lua_newtable(L); // create a table at the top of the stack
  lua_pushstring(L, "zones"); // key
  lua_pushstring(L, lmlinit.zones.c_str()); // value
  lua_settable(L, -3); // t[k] = v  t: given index, v: top (-1), k: below top (-2)

  lua_pushstring(L, "features"); 
  lua_pushstring(L, lmlinit.features.c_str());
  lua_settable(L, -3);
  
  return;
}



////////////////////////////////////////////////////////////////////////////////
////////// h3pgmReader
////////////////////////////////////////////////////////////////////////////////

int h3pgmReader_getTest(lua_State *L)
{
  lua_getglobal(L, "test"); 
  if (!lua_isnumber(L, -1))
  {
    cout << "LUA CALL WARNING: 'test' should be a number" << endl; //error(L, "`test' should be a number\n");
    return -1;
  }
  int test = (int)lua_tonumber(L, -1);
  lua_pop(L,1); // can do without
  return test;
}

string h3pgmReader_getVersion(lua_State *L)
{
  lua_getglobal(L, "version");
  if (!lua_isstring(L, -1))
  {
    cout << "LUA CALL ERROR: 'version' should be a string" << endl; 
    return NULL;
  }
  const char* version = lua_tostring(L, -1);
  string version2( version );
  lua_pop(L,1); // can do without
  return version;
}


LMLInit h3pgmReader_getLMLInit(lua_State *L) 
{
  lua_getglobal(L, "LML_initializer");
  if (!lua_istable(L, -1))
  {
    cout << "LUA CALL ERROR: 'LML_initializer' should be a table" << endl; 
    return {"",""};
  }
  LMLInit lmlinit = LMLInit_pop(L, 1); // positive index - from the bottom
  lua_pop(L,1); // Pop outer table
  return lmlinit; 
}

RandomSeeds h3pgmReader_getRandomSeeds(lua_State *L) 
{
  RandomSeeds rs;
  lua_getglobal(L, "random_seeds");
  if (!lua_istable(L, -1))
  {
    cout << "LUA CALL ERROR: 'random_seeds' should be a table" << endl; 
    return rs;
  }
  rs = RandomSeeds_pop(L, 1);
  lua_pop(L,1);
  return rs; 
}

////////////////////////////////////////////////////////////////////////////////
////////// h3pgmWriter
////////////////////////////////////////////////////////////////////////////////

int h3pgmWriter_load(lua_State *L, string filepath)
{
  lua_getglobal(L, "load");  /* function to be called */
  lua_pushstring(L, filepath.c_str());   /* push 1st argument */
  
  if (lua_pcall(L, 1, 0, 0) != 0)
  {
    cout << "LUA Function Call ERROR: function 'load': " << lua_tostring(L, -1) << endl;
    return 1;
  }
  return 0; // ok
}


int h3pgmWriter_save(lua_State *L, string filepath)
{
  lua_getglobal(L, "save"); 
  lua_pushstring(L, filepath.c_str()); 
  
  if (lua_pcall(L, 1, 0, 0) != 0)
  {
    cout << "LUA Function Call ERROR: function 'save': " << lua_tostring(L, -1) << endl;
    return 1;
  }
  return 0; // ok
}


int h3pgmWriter_setVersion(lua_State *L, string version) // make global handler for that ?? 
{
  lua_getglobal(L, "update");  /* function to be called */
  lua_pushstring(L, "version");   /* push 1st argument */
  lua_pushstring(L, version.c_str());   /* push 2nd argument */
  
  if (lua_pcall(L, 2, 0, 0) != 0)
  {
    cout << "LUA Function Call ERROR: function 'update': " << lua_tostring(L, -1) << endl;
    return 1;
  }

  return 0; // ok
}


int h3pgmWriter_setLMLInit(lua_State *L, LMLInit lmlinit) // make global handler for that ?? 
{ // http://stackoverflow.com/questions/3987837/pushing-a-lua-table
  
  lua_getglobal(L, "update");  /* function to be called */
  lua_pushstring(L, "LML_initializer");   /* push 1st argument */
  LMLInit_push(L, lmlinit); /* push 2nd argument (the entire struct */
  if (lua_pcall(L, 2, 0, 0) != 0)
  {
    cout << "LUA Function Call ERROR: function 'update': " << lua_tostring(L, -1) << endl;
    return 1;
  }

  return 0; // ok
}


////////////////////////////////////////////////////////////////////////////////
////////// LMLGenerator
////////////////////////////////////////////////////////////////////////////////

int LMLGenerator_run(int seed, LMLInit lmlinit) // for now all is encapsulated in one function (!) do we need to make it separate? with lua_State *L, 
{
  lua_State* L = LuaWrap_load("LMLGenerator/LMLGenerator.lua");
  
  lua_getglobal(L, "debug");
  lua_getfield(L, -1, "traceback");
  lua_remove(L, -2);

  lua_getglobal(L, "GenerateLML");  // function to be called 
  lua_pushnumber(L, seed);   // push 1st argument 
  LMLInit_push(L, lmlinit); // push 2nd argument (the entire struct 
  
  if (lua_pcall(L, 2, 0, -4) != 0) // 4th arg: -2 - number_of_f_arguments  (or 0 if no error handling function)
  {
    cout << "LUA Function Call ERROR: function 'GenerateLML': " << lua_tostring(L, -1) << endl;
    return 1;
  }
  
  LuaWrap_close(L);
  
  return 0; // ok // todo - make structure to return LMLGraph
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

int main(int argc, char **argv)
{

  cout << ">> Reading Tests:" << endl;
  
  string filename;
  cout << "Insert filename (with extension) [dot for default load]: ";

  //cin >> filename;
  filename = string("."); // no input for faster tests
  
  if (filename == ".")
  {
    //filename="h3pgm.lua";
    filename="out_mapsaves/test.h3pgm";
    cout << "default load: " << filename << endl;
  }
  
  
  lua_State* H3PGMReader = LuaWrap_load(filename);
  
  cout << "> Loaded " << filename << ".test = " << h3pgmReader_getTest(H3PGMReader) << endl;
  string version = h3pgmReader_getVersion(H3PGMReader);
  cout << "> Loaded " << filename << ".version = " << version << endl;
  LMLInit lmlinit = h3pgmReader_getLMLInit(H3PGMReader);
  cout << "> Loaded " << filename << ".LML_initializer.zones = " << lmlinit.zones << endl;
  cout << "> Loaded " << filename << ".LML_initializer.features = " << lmlinit.features << endl;
  RandomSeeds rs = h3pgmReader_getRandomSeeds(H3PGMReader);
  cout << "> Loaded " << filename << ".RandomSeeds.CellularTerrain = " << rs.CellularTerrain << endl;
  
  LuaWrap_close(H3PGMReader);
  
  
  cout << ">> Writing Tests:" << endl;
  
  lua_State* H3PGMWriter = LuaWrap_load("H3PGMWriter/H3PGMWriter.lua");
  
  h3pgmWriter_load(H3PGMWriter, filename);
  version += "lpha";
  h3pgmWriter_setVersion(H3PGMWriter, version);
  lmlinit.zones += ",L4";
  h3pgmWriter_setLMLInit(H3PGMWriter, lmlinit);
  h3pgmWriter_save(H3PGMWriter, "out_mapsaves/test_2.h3pgm");
  
  LuaWrap_close(H3PGMWriter);
  
  cout << ">> Reread Tests:" << endl;
  
  lua_State* H3PGMReader2 = LuaWrap_load("out_mapsaves/test_2.h3pgm");
  LuaWrap_close(H3PGMReader2);
  cout << "> Still alive :-)" << endl;
  
  
  cout << ">> Calling LMLGenerator:" << endl;
  
  LMLGenerator_run(rs.LMLGenerator, lmlinit);
  
  cout << "> After return from lua" << endl;
  
  
  
  
  
  
  return 0;
}
