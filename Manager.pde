/**
 This render manager manages all objects that need to be rendered.
 Objects can subscribe themselves to this manager to receive render
 updates, or unsubscribe if they are done.
 **/
class RenderManager implements IRender {
  //List of all IRender objects
  ManagedList<IRender> renders = new ManagedList<IRender>();
  /**
   Renders all the objects that have been subscribed to this renderer
   **/
  void render() {
    //Render all objects
    for (IRender r : renders.objects) {
      r.render();
    }
    //And update the renders list
    renders.update();
  }

  //Add a new object
  void add(IRender r) {
    renders.add(r);
  }
  
  /**
  Removes this object
  **/
  void remove(IRender r){
    renders.remove(r);
  }
}

/**
 This update manager manages all objects that need to be updated
 Objectcan subscribed themsleves to this manager to receive updates.
 **/
class UpdateManager implements IUpdate {
  //The list of all update objects
  ManagedList<IUpdate> updates = new ManagedList<IUpdate>();

  /**
   Updates all associated/subscribed objects
   **/
  void update() {
    //Update all actual objects
    for (IUpdate u : updates.objects) {
      u.update();
    }
    //Update the managed list
    updates.update();
  }
  
  //Add a new object to be updated
  void add(IUpdate u){
    updates.add(u);
  }
  
  //Remove an old object from the list
  void remove(IUpdate u){
    updates.remove(u);
  }
}

/**
 A managed list prevents concurrent access problems
 **/
class ManagedList<T> implements IUpdate {
  //The main objects list
  ArrayList<T> objects = new ArrayList<T>();
  //Any objects ready to be added
  private ArrayList<T> toAdd = new ArrayList<T>();
  //Any objects ready to be removed
  private ArrayList<T> toRemove = new ArrayList<T>();

  /**
   Does all the list management
   **/
  void update() {
    //If anyone needs to be removed
    if (toRemove.size() > 0) {
      //Now remove them
      for (T o : toRemove) {
        objects.remove(o);
      }
      //And finally clear the lit
      toRemove.clear();
    }
    //Check if we need to add anything
    if (toAdd.size() > 0) {
      //Add them to the list
      for (T o : toAdd) {
        objects.add(o);
      }
      //Clear the list of things to add
      toAdd.clear();
    }
  }

  /**
   Add a new object to the managedlist
   **/
  void add(T newObj) {
    toAdd.add(newObj);
  }

  /**
   Remove an old object from the managed list
   **/
  void remove(T obj) {
    toRemove.add(obj);
  }
}
