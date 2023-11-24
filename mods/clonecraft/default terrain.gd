
class gen:
    const MARGIN = 5

    static var noise = FastNoise2.new()

    var supBuf := VoxelBuffer.new()
    var bounds := Vector3i()
    var pos:Vector3i


    func initSupBuf(size:Vector3i) -> void:
        supBuf.create(size.x, size.y + (MARGIN * 2), size.z)
        bounds = supBuf.get_size()


    func setSupBuf(x:int, y:int, z:int, val:int, global := true) -> void:
        if global:
            x = (x) - pos.x
            y = (y + MARGIN) - pos.y
            z = (z) - pos.z
        supBuf.set_voxel(val, x, y, z)


    func getSupBuf(x:int, y:int, z:int, global := true) -> int:
        if global:
            x = (x) - pos.x
            y = (y + MARGIN) - pos.y
            z = (z) - pos.z
        if x < 0:
            return 0
        if y < 0:
            return 0
        if z < 0:
            return 0
        if x > bounds.x - 1:
            return 0
        if y > bounds.y - 1:
            return 0
        if z > bounds.z - 1:
            return 0
        return supBuf.get_voxel(x, y, z)


    func genSolid(x:int, y:int, z:int) -> int:
        var pending:int = 0
        if y < (noise.get_noise_2d_single(Vector2(x / 20.0, z / 20.0)) * (120 * noise.get_noise_2d_single(Vector2(x / 50.0, z / 50.0)))) + 30:
            if getSupBuf(x, y + 1, z) == 0:
                pending = 3
            elif getSupBuf(x, y + 5, z) == 0:
                pending = 2
            else:
                pending = 1
        return pending


    func iterate() -> void:
        for ix in bounds.x:
            for iz in bounds.z:
                for iy in bounds.y:
                    var iiy = bounds.y - iy - 1
                    setSupBuf(ix, iiy, iz, genSolid(ix + (pos.x), iiy + (pos.y - MARGIN), iz + (pos.z)), false)


    func blit(buf:VoxelBuffer) -> void:
        buf.copy_channel_from_area(
            supBuf,
            Vector3i(0, MARGIN, 0),
            Vector3i(bounds.x, bounds.y - MARGIN, bounds.z),
            Vector3i.ZERO,
            0
        )


    func _generate_block(buf:VoxelBuffer, rpos:Vector3i, _lod:int) -> void:
        pos = rpos
        initSupBuf(buf.get_size())
        iterate()
        blit(buf)


func _generate_block(buf:VoxelBuffer, rpos:Vector3i, _lod:int) -> void:
    var h:gen = gen.new()
    h._generate_block(buf, rpos, _lod)
    #h.free()
